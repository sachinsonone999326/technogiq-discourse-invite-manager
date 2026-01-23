# frozen_string_literal: true

module ::TechnogiqDiscourseModule
  class InviteManagerController < ::ApplicationController
    requires_plugin PLUGIN_NAME
    #require_dependency "invite_sender"
    #def index
      #render json: { hello: "world" }
    #end
    before_action :ensure_logged_in
    before_action :ensure_admin

    def index
      render json: { 
        invites: [],
        meta: {
          total: 0
        }
      }
    end

    def user
      render json: { 
        users: [],
        meta: {
          total: 0
        }
      }
    end

    def manageinvite
      render json: { 
        manageinvites: [],
        meta: {
          total: 0
        }
      }
    end

    def create
      is_expiry_date = params[:is_expiry_date]
      expiration_date = params[:expiration_date]
      plan_type = params[:plan_type]
      membership_duration_value = params[:membership_duration_value]
      metadata = params[:metadata] || {}

      #invite = Invite.create(invited_by: current_user)
      invite = Invite.create(invited_by: current_user, email: nil, max_redemptions_allowed: 5000)
      raise StandardError, "Failed to create invite" unless invite

      invite_metadata = InviteMetadata.create!(
        invite_id: invite.id,
        is_expiry_date: is_expiry_date,
        expiration_date: is_expiry_date ? expiration_date : nil,
        plan_type: is_expiry_date ? nil : plan_type,
        membership_duration_value: is_expiry_date ? nil : membership_duration_value,
        metadata: metadata
      )

      render json: {
        status: "ok",
        invite_id: invite.id,
        invite_url: "#{Discourse.base_url}/invites/#{invite.invite_key}",
        metadata: invite_metadata.metadata
      }
    rescue => e
      render json: { status: "error", message: e.message }, status: 500
    end
  end
end
