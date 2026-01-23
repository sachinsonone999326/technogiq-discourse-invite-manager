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

    PER_PAGE = 10

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
      page = params[:page].to_i
      page = 1 if page < 1
      per_page = params[:per_page]&.to_i || PER_PAGE

      offset = (page - 1) * per_page

      base_query = InviteMetadata
        .left_joins("LEFT JOIN user_invited ON user_invited.invite_id = invite_metadata.id")
        .group("invite_metadata.id")
        

      total_count = base_query.count.length

      invites = base_query
        .select(
          "invite_metadata.*,
           COUNT(user_invited.id) AS subscriber_count"
        )
        .order("invite_metadata.created_at DESC")
        .limit(per_page)
        .offset(offset)

      render json: {
        invites: invites.map { |i|
          {
            id: i.id,
            plan_type: i.plan_type,
            is_expiry_date: i.is_expiry_date,
            expiration_date: i.expiration_date,
            membership_duration_value: i.membership_duration_value,
            subscriber_count: i.subscriber_count.to_i,
            created_at: i.created_at
          }
        },
        meta: {
          page: page,
          per_page: per_page,
          total: total_count,
          total_pages: (total_count.to_f / per_page).ceil
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
