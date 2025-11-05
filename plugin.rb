# name: technogiq-discourse-invite-manager
# about: Technogiq:- Adds expiration and dynamic metadata to Discourse invitation links
# version: 0.1
# authors: Sachin Sonone
# url: https://github.com/sachinsonone/technogiq-discourse-invite-manager

enabled_site_setting :invite_manager_enabled

after_initialize do
  module ::DiscourseInviteManager
    PLUGIN_NAME = 'technogiq-discourse-invite-manager'
  end

  require_dependency 'application_controller'

  load File.expand_path('../app/controllers/invite_manager_controller.rb', __FILE__)
  load File.expand_path('../app/models/invite_metadata.rb', __FILE__)
  load File.expand_path('../app/jobs/check_invite_expiration.rb', __FILE__)
  load File.expand_path('../lib/invite_manager/engine.rb', __FILE__)

  # Extend Invite model to support metadata
  ::Invite.class_eval do
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

  # Hook: When a new user is created, link to invite and add username
  DiscourseEvent.on(:user_created) do |user|
    invite = Invite.find_by(email: user.email)
    if invite
      invite.set_metadata("username", user.username)
    end
  end
end

