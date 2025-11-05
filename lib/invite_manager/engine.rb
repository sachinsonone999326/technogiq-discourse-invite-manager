module ::InviteManager
  class Engine < ::Rails::Engine
    engine_name 'invite_manager'
    isolate_namespace InviteManager
  end
end

Discourse::Application.routes.append do
  mount ::InviteManager::Engine, at: '/invite_manager'
end

InviteManager::Engine.routes.draw do
  post '/create' => 'invite_manager#create'
end

