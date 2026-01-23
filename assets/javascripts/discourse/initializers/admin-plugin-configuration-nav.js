import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "technogiq-discourse-invite-manager-admin-plugin-configuration-nav",

  initialize(container) {
    const currentUser = container.lookup("service:current-user");
    if (!currentUser || !currentUser.admin) {
      return;
    }

    withPluginApi((api) => {
      api.addAdminPluginConfigurationNav("technogiq-discourse-invite-manager", [
        {
          label: "technogiq_invite_manager.title",
          route: "adminPlugins.show.technogiq-discourse-invite-manager-invites",
          description: "technogiq_invite_manager.title",
        },

       
        {
          label: "technogiq_invite_manager.manageinvites",
          route: "adminPlugins.show.technogiq-discourse-invite-manager-manageinvites",
          description: "technogiq_invite_manager.manageinvites",
        },

         {
          label: "technogiq_invite_manager.manageusers",
          route: "adminPlugins.show.technogiq-discourse-invite-manager-users",
          description: "technogiq_invite_manager.manageusers",
        },

        
      ]);
    });
  },
};
