export default {
  resource: "admin.adminPlugins.show",

  path: "/plugins",

  map() {
    this.route(
      "discourse-invites",
      //"technogiq-discourse-invite-manager-invites",
      { path: "invites" },
     
    );
  },
};
