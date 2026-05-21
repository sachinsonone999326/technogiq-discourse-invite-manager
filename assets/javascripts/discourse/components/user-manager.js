import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import moment from "moment";
import { service } from "@ember/service";
import ExtendMembershipModal from "../components/extend-membership-modal";
import EditMetadataModal from "../components/edit-metadata-modal";

export default class UserManagerGrid extends Component {
  @tracked invites = [];
  @tracked baseUrl = '';
  @tracked page = 1;
  @tracked perPage = 10;
  @tracked totalPages = 1;
  @tracked loading = false;
  @service modal;

  constructor() {
    super(...arguments);
    this.loadInvites();
  }

  async loadInvites() {
    this.loading = true;

    const response = await ajax("/technogiq-discourse-invite-manager/datamanageusers", {
      data: {
        page: this.page,
        per_page: this.perPage
      }
    });

    this.invites = response.invites;
    this.totalPages = response.meta.total_pages;
    this.baseUrl = response.baseUrl;
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
   ExtendMembership(invite) {
   console.log("View", invite);
   this.modal.show(ExtendMembershipModal, {
        model: {invite: invite,
       updateRow: (expirationDate) => {

         invite.expiration_date = expirationDate;

         // trigger rerender
         this.invites = [...this.invites];
        this.loadInvites();
       },
      },

    });
  }

  @action
   EditMetadata(invite) {
   console.log("viewDetails", invite);

  this.modal.show(EditMetadataModal, {
      model: invite,
    });

  }

  formatInviteDate(date) {
    return moment(date).format("DD MMM YYYY, hh:mm a");
  }

  formatInviteDateWithoutTime(date) {
    return moment(date).format("DD MMM YYYY");
  }
}

