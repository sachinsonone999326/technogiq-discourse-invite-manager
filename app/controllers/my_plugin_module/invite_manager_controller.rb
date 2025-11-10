# frozen_string_literal: true

module ::MyPluginModule
  class InviteManagerController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :ensure_logged_in
    before_action :ensure_admin

    def create
      email = params[:email]
      expiration_date = params[:expiration_date]
      metadata = params[:metadata] || {}

      invite = Invite.create_invite_link(invited_by: current_user, email: email)
      invite.set_metadata('expiration_date', expiration_date) if expiration_date.present?
      metadata.each { |k, v| invite.set_metadata(k, v) }

      render json: {
        status: "ok",
        invite_id: invite.id,
        invite_url: "#{Discourse.base_url}/invites/#{invite.invite_key}",
        metadata: invite.invite_metadata.pluck(:key, :value).to_h
      }
    rescue => e
      render json: { status: "error", message: e.message }, status: 500
    end
  end
end
