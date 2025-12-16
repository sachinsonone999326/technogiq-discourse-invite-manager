import Route from "@ember/routing/route";

export default class TechnogiqInvitesRoute extends Route {
  model() {
    return this.store.findAll("technogiq-invite");
  }
}

