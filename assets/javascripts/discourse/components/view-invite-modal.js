import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import moment from "moment";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";

export default class ViewInviteModal extends Component {
  @tracked loading = true;
  @tracked inviteDetails = [];
  @tracked model = [];
  @tracked baseUrl = "";
  @tracked isMaximized = false;
  @tracked copied = false;

  constructor() {
    super(...arguments);
    this.loadDetails();
  }
  
 async loadDetails() {
    try {
     this.model = this.args.model;
      const response = await ajax(
        "/technogiq-discourse-invite-manager/dataallinvitesurl",
        {
          data: {
            batch_id: this.args.model.id
          }
        }
      );

      this.inviteDetails = response; // adjust based on API
    } catch (e) {
      console.error("API error:", e);
    } finally {
      this.loading = false;
      console.log(this.inviteDetails);
       console.log(this.inviteDetails.invites.length);
    }
  }

  @action
    copyToClipboard() {
      this.copied = true;
      const urls = this.inviteDetails.invites
          .map(
            (item) => `${this.inviteDetails.baseUrl}/invites/${item.invite_key}`
          )
          .join("\n");

        navigator.clipboard.writeText(urls);

        // Optional success message
        this.flashMessages?.success("Invite URLs copied to clipboard.");
        setTimeout(() => {
          this.copied = false;
        }, 1500); // 1.5 seconds
    }

    @action
    toggleMaximize() {
      this.isMaximized = !this.isMaximized;
    }


}
