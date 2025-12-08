import DiscourseRoute from "discourse/routes/discourse";

export default class InviteManagerRoute extends DiscourseRoute {
  model() {
    return {
      email: "",
      expiration_date: "",
      metadata: []
    };
  }
}

