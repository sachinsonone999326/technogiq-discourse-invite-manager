import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import moment from "moment";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";

export default class ViewDetailsModal extends Component {

  @tracked loading = true;
  @tracked inviteDetails = [];
  @tracked model = [];
  @tracked metadata = [];
  @tracked baseUrl = "";  


 constructor() {
    super(...arguments);
    this.loadDetails();
  }
  
 async loadDetails() {
    try {
     this.model = this.args.model;
      const response = await ajax(
        "/technogiq-discourse-invite-manager/datainvitedetails",
        {
          data: {
            invite_id: this.args.model.invite_id
          }
        }
      );

      this.inviteDetails = response.invites[0]; // adjust based on API
     
    } catch (e) {
      console.error("API error:", e);
    } finally {
      this.loading = false;
      console.log(this.inviteDetails);
       console.log(this.inviteDetails.invites.length);
    }
  }
  formatInviteDate(date) {
    return moment(date).format("DD MMM YYYY, hh:mm a");
  }

  formatInviteDateWithoutTime(date) {
    return moment(date).format("DD MMM YYYY");
  }
  
  get metadataList() {
  const metadata = this.args.model.metadata || {};
  const excludedKeys = [
    "is_batch_mode",
    "is_expiry_date",
    "renewal_period",
    "expiration_date",
    "renewal_period_value",
    "number_of_invitations",
    "membership_duration_value",
    "plan_type"
  ];
  return Object.keys(metadata)
    .filter((key) => !excludedKeys.includes(key))
    .map((key) => ({
      key,
      value: metadata[key]
    }));
}

}
