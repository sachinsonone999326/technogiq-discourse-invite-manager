import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import moment from "moment";
import { service } from "@ember/service";
import ViewInviteModal from "../components/view-invite-modal";
import ViewDetailsModal from "../components/view-details-modal";

export default class InviteManagerGrid extends Component {
  @tracked invites = [];
  @tracked page = 1;
  @tracked perPage = 10;
  @tracked totalPages = 1;
  @tracked loading = false;
  @service modal;
  @tracked activeTab = "all";

  @tracked searchTerm = "";

  constructor() {
    super(...arguments);
    this.loadInvites();
  }

  async loadInvites() {
    this.loading = true;

    const response = await ajax("/technogiq-discourse-invite-manager/datamanageinvites", {
      data: {
        page: this.page,
        per_page: this.perPage
      }
    });

    this.invites = response.invites;
    this.totalPages = response.meta.total_pages;

    this.loading = false;
  }

  @action
  nextPage() {
    if (this.page < this.totalPages) {
      this.page++;
      this.loadInvites();
    }
  }

  @action
  prevPage() {
    if (this.page > 1) {
      this.page--;
      this.loadInvites();
    }
  }

  @action
   viewInvite(invite) {
   console.log("View", invite);
   this.modal.show(ViewInviteModal, {
      model: invite
    });
  }

  @action
   viewDetails(invite) {
   console.log("viewDetails", invite);

  this.modal.show(ViewDetailsModal, {
      model: invite
    });

  }

  formatInviteDate(date) {
    return moment(date).format("DD MMM YYYY, hh:mm a");
  }

  getRedeemedPercentage(invite) {

    if (!invite.max_redemptions_allowed) {
      return 0;
    }

    return (
      invite.redemption_count
      /
      invite.max_redemptions_allowed
    ) * 100;
  }

  getRemainingPercentage(invite) {

    if (!invite.max_redemptions_allowed) {
      return 0;
    }

    return (
      invite.remaining_redemptions
      /
      invite.max_redemptions_allowed
    ) * 100;
  }

  get filteredInvites() {

  let invites = this.invites || [];

  // TAB FILTER

  if (this.activeTab === "active") {

    invites = invites.filter(
      (i) => !i.is_expired
    );

  }

  if (this.activeTab === "completed") {

    invites = invites.filter(
      (i) => i.is_completed
    );

  }

  // SEARCH FILTER

  if (this.searchTerm) {

    const term =
      this.searchTerm.toLowerCase();

    invites = invites.filter((i) => {

      return (
        String(i.id)
          .toLowerCase()
          .includes(term)

        ||

        (i.description || "")
          .toLowerCase()
          .includes(term)

        ||

        (i.group_names || "")
          .toLowerCase()
          .includes(term)
      );

    });

  }

  return invites;
}

 @action
  changeTab(tab) {
    this.activeTab = tab;
  }

  @action
  downloadInvite(invite) {

  window.open(
    `/technogiq-discourse-invite-manager/download-invites/${invite.id}/download.json`,
    "_blank"
  );

}


}

