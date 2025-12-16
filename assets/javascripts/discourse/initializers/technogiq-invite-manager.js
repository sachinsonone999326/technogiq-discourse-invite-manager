import { withPluginApi } from "discourse/lib/plugin-api";
import InviteModal from "../components/modal/technogiq-invite-modal";

function initializeTechnogiqInviteManager(api) {
  api.addComposerToolbarPopupMenuOption({
    icon: "user-plus",
    label: "technogiq_invites.add",

    action: (toolbarEvent) => {
      api.container.lookup("service:modal").show(InviteModal, {
        model: { toolbarEvent },
      });
    },

    condition: () => {
      const currentUser = api.getCurrentUser();
      const siteSettings = api.container.lookup("service:site-settings");

      return (
        siteSettings.technogiq_invite_manager_enabled &&
        currentUser &&
        currentUser.staff
      );
    },
  });
}

export default {
  name: "technogiq-invite-manager",

  initialize() {
    withPluginApi(initializeTechnogiqInviteManager);
  },
};
