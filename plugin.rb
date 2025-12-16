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

#add_admin_route 'invite_manager.title', 'invite-manager'

#register_asset 'admin/addon/routes/invite-manager.js', :admin
#register_asset 'admin/addon/controllers/invite-manager.js', :admin
#register_asset 'admin/addon/templates/invite-manager.hbs', :admin


after_initialize do
  require_dependency "invite"
  #add_admin_route 'invite_manager.title', 'invite-manager'
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

  #add_admin_route "technogiq-discourse-invite-manager.title", "technogiq-discourse-invite-manager"
  add_admin_route "technogiq-discourse-invite-manager.title", "technogiq-invites"
  Discourse::Application.routes.append do
    #get '/admin/plugins/technogiq-discourse-invite-manager' => 'admin/plugins#index', constraints: StaffConstraint.new
    #get '/admin/plugins/technogiq-invite-manager' => 'admin/plugins#index'
    namespace :admin do
      post "/technogiq/invites" => "technogiq_invites#create"
    end
  end
 # register_asset "javascripts/discourse/routes/admin-invite-manager.js"
 # register_asset "javascripts/discourse/controllers/admin-invite-manager.js"
 # register_asset "javascripts/discourse/templates/admin-invite-manager.hbs"
  # Code which should run after Rails has finished booting
  #Discourse::Application.routes.append do
    #mount ::TechnogiqDiscourseModule::Engine, at: "/technogiq-discourse-invite-manager"
  #end
end

#Discourse::Application.routes.append do
#  mount ::TechnogiqDiscourseModule::Engine, at: "/technogiq_discourse_module"
#end
