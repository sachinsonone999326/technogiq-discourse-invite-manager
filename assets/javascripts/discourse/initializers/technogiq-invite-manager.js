import { withPluginApi } from "discourse/lib/plugin-api";
import { i18n } from "discourse-i18n";

export default {
  name: "technogiq-invite-manager",

  initialize() {
    withPluginApi((api) => {
      /**
       * Register admin page (sidebar + route binding)
       * This is the ONLY supported way now
       */
      api.addAdminPage({
        name: "technogiq-invites",
        label: i18n("technogiq_invites.title"),
        route: "technogiq-invites",
      });
    });
  },
};
