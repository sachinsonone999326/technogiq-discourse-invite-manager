# frozen_string_literal: true
#

#module Jobs
#  class CheckInviteExpiration < ::Jobs::Scheduled
#    every 1.day

#    def execute(args)
#      return true #if !SiteSetting.invite_manager_enabled
#    end
#  end
#end


module Jobs
  class CheckInviteExpiration < ::Jobs::Scheduled
    every 1.day

    def execute(args)
      Rails.logger.info("InviteManager: Running expiration cron job")

      InviteMetadata.where(key: "expiration_date").find_each do |meta|
        begin
          expiration = parse_date(meta.value)
          next if expiration.nil?

          invite = Invite.find_by(id: meta.invite_id)
          next if invite.nil? || !invite.redeemed?

          #user = invite.user
          #user = invite.redeemed_users.first
          #next if user.nil?
          invited_user = InvitedUser.find_by(invite_id: invite.id)
          user = invited_user&.user
          next if user.nil?

          # ----- 5 DAY WARNING -----
          days_left = (expiration - Date.today).to_i

          #if days_left == 5
          #  send_warning_notification(user, expiration)
          #  Rails.logger.info(
          #    "InviteManager: Sent 5-day warning to #{user.username} (expires: #{expiration})"
          #  )
          #end

          if days_left <= 5 && days_left > 0
            send_warning_notification(user, expiration, days_left)
            Rails.logger.info(
              "InviteManager: Sent daily warning to #{user.username}, #{days_left} days left"
            )
          end

          # ----- EXPIRATION CHECK -----
          if expiration < Date.today && user.active?
            user.deactivate("Invite expired")
            Rails.logger.info(
              "InviteManager: Deactivated user #{user.username} due to expired invite (expired on #{expiration})"
            )
          end

        rescue => e
          Rails.logger.error("InviteManager Cron Error: #{e.message}")
        end
      end
    end

    private

    def parse_date(value)
      Date.parse(value) rescue nil
    end

    def send_warning_notification(user, expiration_date, days_left)
      message = <<~MSG
        Your account access will expire in **#{days_left} days** (on **#{expiration_date}**)
        because your invitation has a time limit.

        If you believe this is a mistake or you need an extension,
        please contact the admin.
      MSG

      PostCreator.create!(
        Discourse.system_user,
        #target_user: user,
        target_usernames: user.username,
        archetype: Archetype.private_message,
        subtype: TopicSubtype.system_message,
        title: "Your account will expire soon",
        raw: message
      )
    end
  end
end
