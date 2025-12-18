export default {
  resource: "adminPlugins.show",
  path: "/plugins/technogiq-discourse-invite-manager",
  map() {
    this.route("invites");
  },
};
