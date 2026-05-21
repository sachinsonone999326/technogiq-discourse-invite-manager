import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import moment from "moment";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";

export default class EditMetadataModal extends Component {

  @tracked loading = true;
  @tracked successMessage = null;
  @tracked errorMessage = null;
  @tracked inviteDetails = [];
  @tracked model = [];
  @tracked metadata = [];
  @tracked baseUrl = "";
  @tracked hideform = true;
  @tracked isSaving = false;
  @tracked localMetadata = [{ key: "", value: "" }];

 @tracked initialData = {
    
  };

 constructor() {
    super(...arguments);
    this.loadDetails();
  }
  
 async loadDetails() {
    try {
     this.model = this.args.model;
     console.log(this.args.model);
      const response = await ajax(
        "/technogiq-discourse-invite-manager/datamanageusersbyid",
        {
          data: {
            user_id: this.args.model.id
          }
        }
      );

      this.inviteDetails = response.invites[0]; // adjust based on API
      this.metadata = this.inviteDetails.invite.metadata;
      this.localMetadata = this.metadataList();


     
    } catch (e) {
      console.error("API error:", e);
    } finally {
      this.loading = false;
      console.log(this.inviteDetails);
    }
  }

  
 metadataList() {
  const metadata = this.metadata || {};
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


  @action
  addMetadata2() {
   this.localMetadata = [
    ...this.localMetadata,
    { key: "", value: "" }
  ];

  }

  @action
  removeMetadata2(index) {
    //this.localMetadata.splice(index, 1);
    this.localMetadata = this.localMetadata.filter((_, i) => i !== index);
  }

  @action
  updateMetadata2(index, field, event) {
    const value = event.target.value;

    if (!this.localMetadata[index]) return;

    this.localMetadata[index][field] = value;
  }

  @action
  autoGrow(event) {
    const el = event.target;
    el.style.height = "auto";
    el.style.height = el.scrollHeight + "px";
  }

  buildMetadataObject(metadataArray) {
    const result = {};
    metadataArray.forEach(({ key, value }) => {
      if (key && value) {
        result[key] = value;
      }
    });
    return result;
  }

 @action
  async save(data) {
    this.isSaving = true;
    this.successMessage = null;
    this.errorMessage = null;
    this.inviteUrl = null;
    
    try {
      const payload = {};
        
      const metadataObject = this.buildMetadataObject(this.localMetadata);
      payload.metadata = this.buildMetadataObject(this.localMetadata),
      payload.id = this.inviteDetails.invite.id;

      const response = await ajax(
        "/technogiq-discourse-invite-manager/editmetadata",
        {
          type: "POST",
          contentType: "application/json",
          data: JSON.stringify(payload),
        }
      );

      if (response.status === "ok") {
        this.successMessage = "Updated successfully!";
        this.hideform = false;
      
  } else {
        this.errorMessage = response.message || "Something went wrong.";
      }
    } catch (e) {
      this.errorMessage = e.message || "Failed to update metadata.";
    } finally {
      this.isSaving = false;
    }
  }

}
