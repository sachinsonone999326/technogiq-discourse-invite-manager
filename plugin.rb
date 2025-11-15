# frozen_string_literal: true

# name: technogiq-discourse-invite-manager
# about: Technogiq – Adds expiration and dynamic metadata to Discourse invitation links
# meta_topic_id: TODO
# version: 0.0.1
# authors: Technogiq
# url: https://github.com/sachinsonone999326/technogiq-discourse-invite-manager/

enabled_site_setting :invite_manager_enabled

module ::TechnogiqDiscourseModule
  PLUGIN_NAME = "technogiq-discourse-invite-manager"
end

require_relative "lib/technogiq_discourse_module/engine"
require_relative "app/models/invite_metadata"

after_initialize do
  require_dependency "invite"
  #require_dependency "invite_sender"
  class ::Invite
    has_many :invite_metadata, dependent: :destroy, class_name: "InviteMetadatum", foreign_key: "invite_id"

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
  # Code which should run after Rails has finished booting
  #Discourse::Application.routes.append do
    #mount ::TechnogiqDiscourseModule::Engine, at: "/technogiq-discourse-invite-manager"
  #end
end

#Discourse::Application.routes.append do
#  mount ::TechnogiqDiscourseModule::Engine, at: "/technogiq_discourse_module"
#end
