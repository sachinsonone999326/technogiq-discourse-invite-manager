import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class InviteManagerEditor extends Component {
  @tracked isSaving = false;
  @tracked successMessage = null;
  @tracked errorMessage = null;
  @tracked inviteUrl = null;
  @tracked planTypeOptions = [
  { id: "days", name: "Days" },
  { id: "months", name: "Months" },
  { id: "years", name: "Years" },
  @tracked renewalPeriodOptions = [
  { id: "monthly", name: "Monthly" },
  { id: "quarterly", name: "Quarterly" },
  { id: "half-yearly", name: "Half Yearly" },
  { id: "yearly", name: "Yearly" },
  @tracked expireAfterOptions = [
  { id: "1", name: "1 day" },
  { id: "7", name: "7 days" },
  { id: "30", name: "30 days" },
  { id: "90", name: "90 days" },
  { id: "36500", name: "36500 days" },
  { id: "999999", name: "Never" },
];
  initialData = {
    is_expiry_date: false,
    expiration_date: "",
    plan_type: "monthly",
    membership_duration_value: 1,
    renewal_period_value: 1,
    metadata: [{ key: "", value: "" }],
    description: "",
    restrict_to: "",
    max_uses: 1,
    expire_after: 90,
    arrive_at_topic: 0,
    add_to_groups: 0,
    number_of_invitations : 1,
    is_batch_mode: false,
    
    
  };

  
  parseMetadata(json) {
    try {
      return JSON.parse(json || "{}");
    } catch (e) {
      throw new Error("Metadata must be valid JSON");
    }
  }

  @action
  addMetadata(form, data) {
    form.set("metadata", [...data.metadata, { key: "", value: "" }]);
  }

  @action
  removeMetadata(form, data, index) {
    form.set(
      "metadata",
      data.metadata.filter((_, i) => i !== index)
    );
  }

  @action
  updateMetadata(  form, data, index, field, event) {
    const updated = [...data.metadata];
    updated[index] = {
      ...updated[index],
      [field]: event.target.value,
    };
   
    form.set("metadata", updated);
  
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
      const payload = {
        is_expiry_date: data.is_expiry_date,
        metadata: this.buildMetadataObject(data.metadata),
      };

      if (data.is_expiry_date) {
        payload.expiration_date = data.expiration_date;
      } else {
        payload.plan_type = data.plan_type;
        payload.membership_duration_value = data.membership_duration_value;
      }

      const response = await ajax(
        "/technogiq-discourse-invite-manager/invites",
        {
          type: "POST",
          contentType: "application/json",
          data: JSON.stringify(payload),
        }
      );

      if (response.status === "ok") {
        this.successMessage = "Invite created successfully!";
        this.inviteUrl = response.invite_url;
      } else {
        this.errorMessage = response.message || "Something went wrong.";
      }
    } catch (e) {
      this.errorMessage = e.message || "Failed to create invite.";
      popupAjaxError(e);
    } finally {
      this.isSaving = false;
    }
  }
}
