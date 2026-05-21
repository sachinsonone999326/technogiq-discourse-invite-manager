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
            uniqueid: this.args.model.uniqueid
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


}
