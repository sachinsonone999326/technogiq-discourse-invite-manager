# frozen_string_literal: true

module Jobs
  class CheckInviteExpiration < ::Jobs::Scheduled

    every 1.day

    def execute(args)

      Rails.logger.info(
        "InviteManager: Running expiration cron job"
      )

      UserInviteum
        .where.not(expiration_date: nil)
        .where(
          "expiration_date BETWEEN ? AND ?",
          Date.today - 1.day,
          Date.today + 5.days
        )
        .find_each do |invite_record|

        begin

          user = User.find_by(
            id: invite_record.user_id
          )

          next if user.nil?

          # Skip already deactivated users
          next if user.suspended?

          expiration =
            invite_record.expiration_date.to_date

          days_left =
            (expiration - Date.today).to_i

          # --------------------------------
          # SEND WARNING NOTIFICATION
          # --------------------------------

          if days_left <= 5 &&
             days_left > 0

            send_warning_notification(
              user,
              expiration,
              days_left
            )

            Rails.logger.info(
              "InviteManager: Warning sent to #{user.username}, #{days_left} days left"
            )

          end

          # --------------------------------
          # DEACTIVATE USER
          # --------------------------------

          if expiration < Date.today
          
            user.deactivate(
              "Invite expired"
            )


            user.update_columns(
                suspended_till: 100.years.from_now
            )
            
            #user.update_columns(
            #    suspend_reason: "Your membership has expired. Please contact admin for renewal."
            #)

            UserAuthToken.where(
               user_id: user.id
            ).each(&:destroy!)

            Rails.logger.info(
                "InviteManager: Suspended #{user.username}"
            )

          end

        rescue => e

          Rails.logger.error(
            "InviteManager Cron Error: #{e.message}"
          )

        end
      end
    end

    private

    def send_warning_notification(
      user,
      expiration_date,
      days_left
    )

      message = <<~MSG
        Your account access will expire in **#{days_left} days**
        (on **#{expiration_date}**)
        because your invitation has a time limit.

        If you believe this is a mistake or need extension,
        please contact the admin.
      MSG

      PostCreator.create!(
        Discourse.system_user,
        target_usernames: user.username,
        archetype: Archetype.private_message,
        subtype: TopicSubtype.system_message,
        title: "Your account will expire soon",
        raw: message
      )

    end
  end
end
