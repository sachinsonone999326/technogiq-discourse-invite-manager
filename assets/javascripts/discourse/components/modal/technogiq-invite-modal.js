import Component from "@glimmer/component";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default class TechnogiqInviteModal extends Component {
  email = "";

  @action
  createInvite() {
    ajax("/admin/technogiq/invites", {
      type: "POST",
      data: { email: this.email },
    }).then(() => {
      this.args.closeModal();
    });
  }
}

