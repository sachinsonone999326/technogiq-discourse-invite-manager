import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class InviteManagerEditor extends Component {
  @tracked isSaving = false;

  // Initial form state
  initialData = {
    email: "",
    expiration_date: "",
    metadata: [],
  };

  @action
  addMetadata(form, data) {
    form.set(
      "metadata",
      [...(data.metadata || []), { key: "", value: "" }]
    );
  }

  @action
  removeMetadata(form, data, index) {
    const updated = data.metadata.filter((_, i) => i !== index);
    form.set("metadata", updated);
  }

  buildMetadataObject(metadataArray) {
    const result = {};
    (metadataArray || []).forEach(({ key, value }) => {
      if (key && value) {
        result[key] = value;
      }
    });
    return result;
  }

  @action
  async save(formData) {
    this.isSaving = true;

    try {
      await ajax("/technogiq-discourse-invite-manager/invites", {
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify({
          email: formData.email,
          expiration_date: formData.expiration_date,
          metadata: this.buildMetadataObject(formData.metadata),
        }),
      });
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.isSaving = false;
    }
  }
}
