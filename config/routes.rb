# frozen_string_literal: true

MyPluginModule::Engine.routes.draw do
  post "/invites" => "invites#create"
  # define routes here
end

Discourse::Application.routes.draw { mount ::MyPluginModule::Engine, at: "my-plugin" }
