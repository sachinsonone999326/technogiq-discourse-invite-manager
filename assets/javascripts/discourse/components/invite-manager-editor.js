import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { debounce } from "@ember/runloop";

export default class InviteManagerEditor extends Component {
  @tracked isSaving = false;
  @tracked successMessage = null;
  @tracked errorMessage = null;
  @tracked inviteUrl = null;
  @tracked localMetadata = [{ key: "", value: "" }];
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
  @tracked expireAfterOptions = [
  { id: 1, name: "1 day" },
  { id: 7, name: "7 days" },
  { id: 30, name: "30 days" },
  { id: 90, name: "90 days" },
  { id: 36500, name: "36500 days" },
  { id: 999999, name: "Never" },
];
  initialData = {
    is_expiry_date: false,
    expiration_date: "",
    plan_type: "days",
    membership_duration_value: 1,
    renewal_period_value: 1,
    renewal_period: 'monthly',
    metadata: [{ key: "", value: "" }],
    description: "",
    restrict_to: "",
    max_uses: 1,
    expire_after: 90,
    arrive_at_topic: "",
    add_to_groups: "",
    number_of_invitations : 1,
    is_batch_mode: false,
    
    
  };

  
  constructor() {
    super(...arguments);

   // const metadata = this.initialData.metadata || [];

    //this.localMetadata = JSON.parse(JSON.stringify(metadata));
    this.localMetadata = [{ key: "", value: "" }];
  }

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
   addMetadata1() {
    this.localMetadata = [
    ...this.localMetadata,
    { key: "", value: "" }
  ];
  }

  @action
   removeMetadata1(index) {
  this.localMetadata = this.localMetadata.filter((_, i) => i !== index);
  }
  
  @action
  updateMetadata1(index, field, event) {
  const value = event.target.value;

  this.localMetadata[index][field] = value;

  // trigger reactivity
  this.localMetadata = [...this.localMetadata];
}

  @action
  updateMetadata(  form, data, index, field, event) {
    
  const value = event.target.value;

  debounce(this, this._updateMetadata, form, data, index, field, value, 300);  

/*    const value = event.target.value;
    const updated = data.metadata.map((item, i) => {
    if (i === index) {
      return {
        ...item,
        [field]: value
      };
    }
    return item;
  });
    //form.set("metadata", updated);
    this.localMetadata = [...this.localMetadata, updated];
    */
  }

  _updateMetadata(form, data, index, field, value) {
  const updated = data.metadata.map((item, i) => {
    if (i === index) {
      return {
        ...item,
        [field]: value
      };
    }
    return item;
  });

  form.set("metadata", updated);
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
    //data.metadata = this.localMetadata;
    //form.set("metadata", updated);
   // const metadataObject = {};
   // const updated = data.metadata;

    //updated.forEach(item => {
    //  metadataObject[item.key] = item.value;
   // });
    //console.log(data.metadata, metadataObject);
   // data.metadata = metadataObject;
   const metadataObject = this.buildMetadataObject(this.localMetadata);
   console.log(this.localMetadata, metadataObject);

    try {
      const payload = {
        is_expiry_date: data.is_expiry_date,
        //metadata: this.buildMetadataObject(data.metadata),
        metadata: this.buildMetadataObject(this.localMetadata),
        //metadata: metadataObject,
      };

      if (data.is_expiry_date) {
        payload.expiration_date = data.expiration_date;
      } else {
        payload.plan_type = data.plan_type;
        payload.membership_duration_value = data.membership_duration_value;
      }

      payload.renewal_period_value = data.renewal_period_value;
      payload.renewal_period = data.renewal_period;

      payload.description = data.description;
      payload.restrict_to = data.restrict_to;
      payload.max_uses = data.max_uses;
      payload.expire_after = data.expire_after;
      payload.arrive_at_topic = data.arrive_at_topic;
      payload.add_to_groups = data.add_to_groups;
      payload.number_of_invitations = data.number_of_invitations;
      payload.is_batch_mode = data.is_batch_mode;

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

        this.localMetadata = [{ key: "", value: "" }];
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

  get expiryValidation() {
  return (value, data) => {
    if (data.is_expiry_date && !value) {
      return "Expiration date is required";
    }
    return true;
  };
}
}
