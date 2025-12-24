import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class InviteManagerEditor extends Component {
  @tracked isSaving = false;

  initialData = {
    email: "",
    expiration_date: "",
    metadata: [{ key: "", value: "" }],
  };

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
  updateMetadata(form, data, index, field, event) {
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
      const response = await ajax("/technogiq-discourse-invite-manager/invites", {
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify({
          email: data.email,
          expiration_date: data.expiration_date,
          metadata: this.buildMetadataObject(data.metadata),
        }),
      });

      

        if (response.status === "ok") {
          this.successMessage = "Invite created successfully!";
          this.inviteUrl = response.invite_url;
        } else {
          this.errorMessage = response.message || "Something went wrong.";
        }
      
    } catch (e) {
      this.errorMessage = "Failed to create invite.";
      popupAjaxError(e);
    } finally {
      this.isSaving = false;
    }
  }
}
