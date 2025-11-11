# frozen_string_literal: true

TechnogiqDiscourseModule::Engine.routes.draw do
  post "/invites" => "invites#create"
  # define routes here
end

Discourse::Application.routes.draw { mount ::TechnogiqDiscourseModule::Engine, at: "my-plugin" }
