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

  initialData = {
    is_expiry_date: false,
    expiration_date: "",
    plan_type: "monthly",
    membership_duration_value: 1,
    metadata_json: "{}",
  };

  planTypeOptions = ["days", "monthly", "quarterly", "half-yearly", "yearly"];

  parseMetadata(json) {
    try {
      return JSON.parse(json || "{}");
    } catch (e) {
      throw new Error("Metadata must be valid JSON");
    }
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
        metadata: this.parseMetadata(data.metadata_json),
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
