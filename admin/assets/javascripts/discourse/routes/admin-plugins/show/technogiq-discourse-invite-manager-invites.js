import DiscourseRoute from "discourse/routes/discourse";

export default class TechnogiqDiscourseInviteManagerInvitesRoute extends DiscourseRoute {
  model() {
    return this.store.findAll("invites");
  }
}
