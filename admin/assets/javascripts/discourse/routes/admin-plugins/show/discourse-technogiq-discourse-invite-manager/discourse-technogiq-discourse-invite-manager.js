import EmberObject from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import DiscourseRoute from "discourse/routes/discourse";

export default class DiscourseTechnogiqDiscourseInviteManagerNew extends DiscourseRoute {
  @service currentUser;

  async model() {
    if (!this.currentUser?.admin) {
      return { model: null };
    }

    try {
      const model = await ajax("/admin/plugins/technogiq-discourse-invite-manager/new.json");

     

      return model;
    } catch (err) {
      popupAjaxError(err);
    }
  }
}
