import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "technogiq-invite-manager-route",

  initialize() {
    withPluginApi("0.8.7", (api) => {
      api.addAdminRoute(
        "technogiq_discourse_invite_manager.invites",
        "technogiq-discourse-invite-manager-invites"
      );
    });
  },
};
