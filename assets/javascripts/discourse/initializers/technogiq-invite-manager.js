import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "technogiq-invite-manager",

  initialize() {
    withPluginApi("1.20.0", (api) => {
      api.addAdminRoute(
        "technogiq_invites",
        "technogiq-invites"
      );
    });
  },
};

