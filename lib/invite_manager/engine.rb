module TechnogiqDiscourseInviteManager
  class Engine < ::Rails::Engine
    engine_name "technogiq_discourse_invite_manager"
    isolate_namespace TechnogiqDiscourseInviteManager

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::TechnogiqDiscourseInviteManager::Engine, at: "/invite_manager"
      end
    end
  end
end
