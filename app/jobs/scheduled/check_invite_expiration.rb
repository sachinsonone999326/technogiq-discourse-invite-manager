module Jobs
  class CheckInviteExpiration < ::Jobs::Scheduled
    every 1.day

    def execute(args)
      InviteMetadata.where(key: 'expiration_date').find_each do |meta|
        begin
          expiry = Date.parse(meta.value) rescue nil
          next unless expiry && expiry < Date.today

          invite = Invite.find_by(id: meta.invite_id)
          next unless invite&.redeemed?

          user = User.find_by(email: invite.email)
          if user && user.active?
            user.deactivate
            Rails.logger.info("DiscourseInviteManager: Deactivated expired user #{user.username} (Invite ID #{invite.id})")
          end
        rescue => e
          Rails.logger.error("DiscourseInviteManager Error: #{e.message}")
        end
      end
    end
  end
end

