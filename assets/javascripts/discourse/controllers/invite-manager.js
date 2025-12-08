import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default class InviteManagerController extends Controller {
  responseMessage = null;

  @action
  addMetadata() {
    this.model.metadata.pushObject({ key: "", value: "" });
  }

  @action
  removeMetadata(index) {
    this.model.metadata.removeAt(index);
  }

  @action
  generateInvite() {
    const data = {
      email: this.model.email,
      expiration_date: this.model.expiration_date,
      metadata: {}
    };

    this.model.metadata.forEach(pair => {
      if (pair.key.trim()) {
        data.metadata[pair.key] = pair.value;
      }
    });

    ajax("/technogiq-discourse-invite-manager/invites", {
      type: "POST",
      data
    })
      .then(result => {
        this.set("responseMessage", `Invite created: ${JSON.stringify(result)}`);
      })
      .catch(err => {
        this.set("responseMessage", `Error: ${err.responseText}`);
      });
  }
}

