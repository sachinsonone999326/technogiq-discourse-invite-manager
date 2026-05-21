import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import moment from "moment";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";

export default class ExtendMembershipModal extends Component {

  @tracked loading = true;
  @tracked successMessage = null;
  @tracked errorMessage = null;
  @tracked inviteDetails = [];
  @tracked model = [];
  @tracked metadata = [];
  @tracked baseUrl = "";
  @tracked newExpiryDate = ""; 
  @tracked extendByDuration = false;
  @tracked extendByDate = false;  
  @tracked selectedMode = null;
  @tracked hideform = true;
  @tracked planTypeOptions = [
  { id: "days", name: "Days" },
  { id: "months", name: "Months" },
  { id: "years", name: "Years" },
  ];
  @tracked renewalPeriodOptions = [
  { id: "monthly", name: "Monthly" },
  { id: "quarterly", name: "Quarterly" },
  { id: "half-yearly", name: "Half Yearly" },
  { id: "yearly", name: "Yearly" },
  ];

  @tracked membershipDurationValue = 1;
  @tracked planType = "days";
  @tracked isSaving = false;

 @tracked initialData = {
    is_expiry_date: false,
    expiration_date: "",
    plan_type: "days",
    membership_duration_value: 1,
    renewal_period_value: 1,
    renewal_period: 'monthly',
    
  };

 constructor() {
    super(...arguments);
    this.loadDetails();
  }
  
 async loadDetails() {
    try {
     this.model = this.args.model.invite;
     console.log(this.args);
      const response = await ajax(
        "/technogiq-discourse-invite-manager/datamanageusersbyid",
        {
          data: {
            user_id: this.args.model.invite.id
          }
        }
      );

      this.inviteDetails = response.invites[0]; // adjust based on API
      this.metadata = this.inviteDetails.invite.metadata;
 
      this.initialData = {
               is_expiry_date: false,
               //expiration_date: this.formatInviteDateWithoutTimeForExpiry(this.inviteDetails.invite.expiration_date),
               //plan_type: this.inviteDetails.invite.plan_type,
               //membership_duration_value: this.inviteDetails.invite.membership_duration_value,
               renewal_period_value: this.metadata.renewal_period_value,
               renewal_period: this.metadata.renewal_period,
               expiration_date: "",
               plan_type: "days",
               membership_duration_value: 1,

    
       };

       this.calculateExpiry();

     
    } catch (e) {
      console.error("API error:", e);
    } finally {
      this.loading = false;
      console.log(this.inviteDetails);
    }
  }
  formatInviteDate(date) {
    return moment(date).format("DD MMM YYYY, hh:mm a");
  }

  formatInviteDateWithoutTime(date) {
    return moment(date).format("DD MMM YYYY");
  }

  formatInviteDateWithoutTimeForExpiry(date) {
    return moment(date).format("YYYY-MM-DD");
  }

  
  get metadataList() {
  const metadata = this.args.model.invite.metadata || {};
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
changeExtendMode()
{
  this.extendByDate = false;
  this.extendByDuration = true;
  this.selectedMode = "duration";
}

@action
changeExtendModebyDate()
{
  this.extendByDuration = false;
  this.extendByDate = true;
  this.selectedMode = "date";
}

calculateExpiry() {
  const baseDate = moment(this.inviteDetails.invite.expiration_date);
  switch (this.planType) {
    case "days":
      this.newExpiryDate = baseDate
        .add(this.membershipDurationValue, "day")
        .format("DD MMM YYYY");
      break;

    case "months":
      this.newExpiryDate = baseDate
        .add(this.membershipDurationValue, "month")
        .format("DD MMM YYYY");
      break;

    case "years":
      this.newExpiryDate = baseDate
        .add(this.membershipDurationValue, "year")
        .format("DD MMM YYYY");
      break;
  }
}

@action
updateDuration(event) {
  this.membershipDurationValue = Number(event.target.value);
  this.calculateExpiry();
}

@action
updatePlanType(value) {
  this.planType = event.target.value;
  this.calculateExpiry();
}

 @action
  async save(data) {
    this.isSaving = true;
    this.successMessage = null;
    this.errorMessage = null;
    this.inviteUrl = null;
    
    try {
      const payload = {};
        
      if (this.selectedMode == "date") {
        payload.expiration_date = data.expiration_date;
      } else {
        payload.plan_type = data.plan_type;
        payload.membership_duration_value = data.membership_duration_value;
        payload.expiration_date = moment(this.newExpiryDate, "DD MMM YYYY" ).format("YYYY-MM-DD");
      }
      payload.selectedMode = this.selectedMode;
      payload.renewal_period_value = data.renewal_period_value;
      payload.renewal_period = data.renewal_period;
      payload.id = this.inviteDetails.invite.id;

      const response = await ajax(
        "/technogiq-discourse-invite-manager/updateExpiryDate",
        {
          type: "POST",
          contentType: "application/json",
          data: JSON.stringify(payload),
        }
      );

      if (response.status === "ok") {
        this.successMessage = "Updated successfully!";
        this.hideform = false;
        //console.log(parent);
        //parent.loadInvites();
       // window.location.reload();
       // if (this.args.updateRow) {
          this.args.model.updateRow(payload.expiration_date);
       // }
      
  } else {
        this.errorMessage = response.message || "Something went wrong.";
      }
    } catch (e) {
      this.errorMessage = e.message || "Failed to update Expiry Date.";
    } finally {
      this.isSaving = false;
    }
  }

}
