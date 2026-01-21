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
    has_many :user_invited, dependent: :destroy, class_name: "UserInviteum", foreign_key: "invite_id"

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

  class ::User
    has_many :user_invited, dependent: :destroy, class_name: "UserInviteum", foreign_key: "user_id"

  end

  #add_admin_route "technogiq-discourse-invite-manager.title", "technogiq-discourse-invite-manager"
  add_admin_route "technogiq_invite_manager.title", "technogiq-discourse-invite-manager", use_new_show_route: true
  Discourse::Application.routes.append do
    get "/admin/plugins/technogiq-discourse-invite-manager/invites" => "technogiq_discourse_module/invite_manager#index",
        :constraints => StaffConstraint.new
    #get "/admin/plugins/technogiq-discourse-invite-manager" => "technogiq_discourse_module/invite_manager#index",
    #   :constraints => StaffConstraint.new
    #get '/admin/plugins/technogiq-discourse-invite-manager' => 'admin/plugins#index', constraints: StaffConstraint.new
    #get '/admin/plugins/technogiq-invite-manager' => 'admin/plugins#index'
    namespace :admin do
      #get  "/technogiq-invite-manager" =>
       # "technogiq_discourse_module/invite_manager#index"

      #post "/technogiq-invite-manager" =>
      #  "technogiq_discourse_module/invite_manager#create"
    end
  end
 # register_asset "javascripts/discourse/routes/admin-invite-manager.js"
 # register_asset "javascripts/discourse/controllers/admin-invite-manager.js"
 # register_asset "javascripts/discourse/templates/admin-invite-manager.hbs"
  # Code which should run after Rails has finished booting
  #Discourse::Application.routes.append do
    #mount ::TechnogiqDiscourseModule::Engine, at: "/technogiq-discourse-invite-manager"
  #end

  DiscourseEvent.on(:user_created) do |user|
    # Find the invite used by this user
    invite = InvitedUsers.find_by(user_id: user.id)
    next unless invite

    invite_metadata = InviteMetadatum.find_by(invite_id: invite.invite_id)
    next unless invite_metadata

    # Prevent duplicate row
    next if UserInvited.exists?(user_id: user.id)

    expiration_date = nil
    calculate_date = nil

    if invite_metadata.is_expiry_date
      expiration_date = invite_metadata.expiration_date
      calculate_date = expiration_date
    else
      calculate_date = calculate_expiry_date(
        user.created_at,
        invite_metadata.plan_type,
        invite_metadata.membership_duration_value
      )
      expiration_date = calculate_date
    end

    UserInvited.create!(
      user_id: user.id,
      invite_id: invite.id,
      metadata: invite_metadata.metadata || {},
      is_expiry_date: invite_metadata.is_expiry_date,
      expiration_date: expiration_date,
      calculate_date: calculate_date,
      plan_type: invite_metadata.plan_type,
      membership_duration_value: invite_metadata.membership_duration_value
    )
  end

  def calculate_expiry_date(start_date, plan_type, value)
    case plan_type
    when "days"
      start_date + value.days
    when "monthly"
      start_date + value.months
    when "quarterly"
      start_date + (value * 3).months
    when "half-yearly"
      start_date + (value * 6).months
    when "yearly"
      start_date + value.years
    else
      nil
    end
  end
end

#Discourse::Application.routes.append do
#  mount ::TechnogiqDiscourseModule::Engine, at: "/technogiq_discourse_module"
#end
