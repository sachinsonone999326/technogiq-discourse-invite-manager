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

after_initialize do
  # Code which should run after Rails has finished booting
end
