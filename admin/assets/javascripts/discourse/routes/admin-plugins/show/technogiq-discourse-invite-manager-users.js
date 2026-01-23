import DiscourseRoute from "discourse/routes/discourse";

export default class TechnogiqDiscourseInviteManagerUsersRoute extends DiscourseRoute {
  model() {
    return this.store.findAll("user");
  }
}
