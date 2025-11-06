# frozen_string_literal: true

# name: technogiq-discourse-invite-manager
# about: Technogiq – Adds expiration and dynamic metadata to Discourse invitation links
# version: 0.1
# authors: Sachin Sonone
# url: https://github.com/sachinsonone/technogiq-discourse-invite-manager

enabled_site_setting :invite_manager_enabled

module ::TechnogiqDiscourseInviteManager
  PLUGIN_NAME = "technogiq-discourse-invite-manager"
end

require_relative "lib/invite_manager/engine"

after_initialize do
  require_dependency "application_controller"
  require_dependency "invite"

  # Load plugin components
  require_relative "app/controllers/invite_manager_controller"
  require_relative "app/models/invite_metadata"
  # ⚠️ Do not manually load jobs if located in app/jobs/scheduled/
  # Discourse autoloads them automatically.
  # Example correct location: app/jobs/scheduled/check_invite_expiration.rb

  #
  # --- Extend the Invite model to support metadata ---
  #
  class ::Invite
    has_many :invite_metadata, dependent: :destroy

    def set_metadata(key, value)
      record = invite_metadata.find_or_initialize_by(key: key)
      record.value = value.is_a?(Hash) ? value.to_json : value.to_s
      record.save!
    end

    def get_metadata(key)
      record = invite_metadata.find_by(key: key)
      record&.value
    end
  end

  #
  # --- Add username metadata automatically when user registers ---
  #
  DiscourseEvent.on(:user_created) do |user|
    invite = Invite.find_by(email: user.email)
    next unless invite

    invite.set_metadata("username", user.username)
  end
end
