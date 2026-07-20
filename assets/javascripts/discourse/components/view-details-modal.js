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
  @tracked isMaximized = false;


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
            batch_id: this.args.model.id
          }
        }
      );

      this.inviteDetails = response.invite; // adjust based on API
     
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
  const metadata = this.inviteDetails.metadata || {};
  const excludedKeys = [
    
  ];
  return Object.keys(metadata)
    .filter((key) => !excludedKeys.includes(key))
    .map((key) => ({
      key,
      value: metadata[key]
    }));
}

get topicNames() {
  return (this.inviteDetails?.topics || [])
    .map(t => t.title)
    .join(", ");
}

get groupNames() {
  return (this.inviteDetails?.groups || [])
    .map(t => t.name)
    .join(", ");
}

@action
toggleMaximize() {
  this.isMaximized = !this.isMaximized;
}

}
