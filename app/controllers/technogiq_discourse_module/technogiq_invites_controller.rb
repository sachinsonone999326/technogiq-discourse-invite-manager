# frozen_string_literal: true

class TechnogiqInvitesController < ::Admin::AdminController
  requires_plugin "technogiq-discourse-invite-manager"

  def create
    invite = Invite.generate(
      current_user,
      email: params[:email],
      max_redemptions: 1
    )

    render_json_dump(
      success: true,
      invite_link: invite.url
    )
  end
end
