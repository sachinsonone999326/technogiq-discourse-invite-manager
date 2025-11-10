# frozen_string_literal: true

# name: technogiq-discourse-invite-manager
# about: Technogiq – Adds expiration and dynamic metadata to Discourse invitation links
# meta_topic_id: TODO
# version: 0.0.1
# authors: Technogiq
# url: https://github.com/sachinsonone/technogiq-discourse-invite-manager

enabled_site_setting :invite_manager_enabled

module ::MyPluginModule
  PLUGIN_NAME = "technogiq-discourse-invite-manager"
end

require_relative "lib/my_plugin_module/engine"

after_initialize do
  require_dependency "application_controller"
  require_dependency "invite"

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
end
