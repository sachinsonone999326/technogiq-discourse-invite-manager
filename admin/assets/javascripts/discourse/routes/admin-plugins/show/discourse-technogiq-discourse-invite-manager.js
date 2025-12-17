import DiscourseRoute from "discourse/routes/discourse";

export default class TechnogiqDiscourseInviteManagerTechnogiqDiscourseInviteManagerRoute extends DiscourseRoute {
  model() {
    return this.store.findAll("technogiq-discourse-invite-manager");
  }
}
