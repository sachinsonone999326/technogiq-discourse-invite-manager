# frozen_string_literal: true

#module ::TechnogiqDiscourseModule
#  class Engine < ::Rails::Engine
#    engine_name PLUGIN_NAME
#    isolate_namespace TechnogiqDiscourseModule
#    config.autoload_paths << File.join(config.root, "lib")
#    scheduled_job_dir = "#{config.root}/app/jobs/scheduled"
#    config.to_prepare do
#      Rails.autoloaders.main.eager_load_dir(scheduled_job_dir) if Dir.exist?(scheduled_job_dir)
#    end
#  end
#end


module ::TechnogiqDiscourseModule
  class Engine < ::Rails::Engine
    engine_name "technogiq_discourse_module"
    isolate_namespace TechnogiqDiscourseModule

    config.autoload_paths << File.join(config.root, "lib")

    scheduled_job_dir = "#{config.root}/app/jobs/scheduled"
    config.to_prepare do
      if Dir.exist?(scheduled_job_dir)
        Rails.autoloaders.main.eager_load_dir(scheduled_job_dir)
      end
    end

    # Engine routes
    initializer "technogiq_discourse_module.routes" do
      TechnogiqDiscourseModule::Engine.routes.draw do
        get "/admin/plugins/technogiq-discourse-invite-manager" =>
          "invite_manager#index"

        post "/admin/plugins/technogiq-discourse-invite-manager" =>
          "invite_manager#create"
      end
    end

  end
end
