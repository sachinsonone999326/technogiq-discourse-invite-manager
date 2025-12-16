import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class TechnogiqInviteManagerController extends Controller {
  email = "";
  expiration_date = "";
  metadataJson = "{}";
  inviteUrl = null;

  @action
  async createInvite() {
    try {
      const metadata = JSON.parse(this.metadataJson || "{}");

      const result = await ajax(
        "/admin/technogiq-invite-manager/invites",
        {
          type: "POST",
          data: {
            email: this.email,
            expiration_date: this.expiration_date,
            metadata,
          },
        }
      );

      this.inviteUrl = result.invite_url;
    } catch (e) {
      popupAjaxError(e);
    }
  }
}
