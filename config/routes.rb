# frozen_string_literal: true

TechnogiqDiscourseModule::Engine.routes.draw do
  #post "/invites" => "invites#create"
  post "/invites" => "invite_manager#create"
  get "/datamanageinvites" => "invite_manager#datamanageinvites"
  get "/dataallinvitesurl" => "invite_manager#dataallinvitesurl"

  get "/datainvitedetails" => "invite_manager#datainvitedetails"

  get "/datamanageusers" => "invite_manager#datamanageusers"
  
  get "/datamanageusersbyid" => "invite_manager#datamanageusersbyid"
  post "/updateExpiryDate" => "invite_manager#extendmembershipupdate"
  post "/editmetadata" => "invite_manager#editmetadata"

  get "/membershipexpiry" => "invite_manager#membership_expiry"
  get "/download-invites/:id/download.json" => "invite_manager#download_json"
  # define routes here
end

Discourse::Application.routes.draw { mount ::TechnogiqDiscourseModule::Engine, at: "technogiq-discourse-invite-manager" }
