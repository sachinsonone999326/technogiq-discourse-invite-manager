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
      render json: { status: "ok", message: "Invite route active" }
    end

    def create
      #require_dependency "invite_sender"
      email = params[:email]
      expiration_date = params[:expiration_date]
      metadata = params[:metadata] || {}
      # Create the Discourse invite
      invite = Invite.create(email: email, invited_by: current_user)
      raise StandardError, "Failed to create invite" unless invite

      # Save metadata using your custom invite_metadata table
      invite.set_metadata("expiration_date", expiration_date) if expiration_date.present?

      metadata.each do |k, v|
        invite.set_metadata(k, v)
      end

      render json: {
        status: "ok",
        invite_id: invite.id,
        invite_url: "#{Discourse.base_url}/invites/#{invite.invite_key}",
        metadata: invite.invite_metadata.pluck(:key, :value).to_h
      }
      #invite = Invite.create_invite_link(invited_by: current_user, email: email)
      #invite = Invite.invite_by_email(email, current_user)
      #invite_sender = InviteSender.new(current_user)
      #invite = invite_sender.create_invite(email: email)
      ##invite = Invite.generate(
      ##  current_user, # inviter
      ##  email: email,
      ##  invited_by: current_user,
      ##  expires_at: expiration_date
     ## )

      #invite.set_metadata('expiration_date', expiration_date) if expiration_date.present?
      #metadata.each { |k, v| invite.set_metadata(k, v) }
      ##invite.custom_fields ||= {}
      #invite.custom_fields["expiration_date"] = expiration_date if expiration_date.present?  metadata.each { |k, v| invite.custom_fields[k] = v }  invite.save!


      ##render json: {
       ## status: "ok",
       # invite_id: invite.id,
       # invite_url: "#{Discourse.base_url}/invites/#{invite.invite_key}",
        # metadata: invite.invite_metadata.pluck(:key, :value).to_h
      ##  custom_fields: invite.custom_fields
     ## }


    rescue => e
      render json: { status: "error", message: e.message }, status: 500
    end
  end
end
