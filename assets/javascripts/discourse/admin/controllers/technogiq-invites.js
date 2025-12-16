import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default class TechnogiqInvitesController extends Controller {
  email = "";

  @action
  createInvite() {
    ajax("/admin/technogiq/invites", {
      type: "POST",
      data: { email: this.email },
    }).then(() => {
      this.set("email", "");
      this.send("refreshModel");
    });
  }
}

