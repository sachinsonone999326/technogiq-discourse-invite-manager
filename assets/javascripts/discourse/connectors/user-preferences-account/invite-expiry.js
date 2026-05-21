import { ajax } from "discourse/lib/ajax";

export default {
  setupComponent(args, component) {

    ajax("/technogiq-discourse-invite-manager/membershipexpiry")
      .then((result) => {

        component.set(
          "expiryDate",
          result.expiry_date
        );

      })
      .catch((error) => {
        console.error(error);
      });

  },

  formatInviteDateWithoutTime(date) {
    return moment(date).format("DD MMM YYYY");
  }
};
