export default {
  resource: "admin.adminPlugins.show",

  path: "/plugins",

  map() {
    this.route(
      "technogiq-discourse-invite-manager-invites",
      { path: "invites" },
     
    );
  },
};
