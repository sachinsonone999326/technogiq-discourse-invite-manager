import Component from "@glimmer/component";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { tracked } from "@glimmer/tracking";

export default class InviteManagerForm extends Component {
  @tracked email = "";
  @tracked expirationDate = "";
  @tracked plan = "";
  @tracked source = "";
  @tracked campaign = "";
  @tracked isSaving = false;
  @tracked successMessage = "";
  @tracked errorMessage = "";

  @action
  async submitInvite() {
    this.isSaving = true;
    this.successMessage = "";
    this.errorMessage = "";

    try {
      await ajax("/technogiq-discourse-invite-manager/invites", {
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify({
          email: this.email,
          expiration_date: this.expirationDate,
          metadata: {
            plan: this.plan,
            source: this.source,
            campaign: this.campaign,
          },
        }),
      });

      this.successMessage = "Invite created successfully";
      this.email = "";
      this.expirationDate = "";
      this.plan = "";
      this.source = "";
      this.campaign = "";
    } catch (e) {
      this.errorMessage = "Failed to create invite";
    } finally {
      this.isSaving = false;
    }
  }
}
