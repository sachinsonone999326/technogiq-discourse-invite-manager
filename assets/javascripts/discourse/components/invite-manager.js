import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default class InviteManagerGrid extends Component {
  @tracked invites = [];
  @tracked page = 1;
  @tracked perPage = 10;
  @tracked totalPages = 1;
  @tracked loading = false;

  constructor() {
    super(...arguments);
    this.loadInvites();
  }

  async loadInvites() {
    this.loading = true;

    const response = await ajax("/invite-manager", {
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
}

