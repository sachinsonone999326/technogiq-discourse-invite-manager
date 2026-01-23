export default {
  resource: "admin.adminPlugins.show",

  path: "/plugins",

  map() {
    this.route(
      "technogiq-discourse-invite-manager-invites",
      { path: "invites" },
     
    );

    this.route(
      "technogiq-discourse-invite-manager-users",
      { path: "users" }
    );

    this.route(
      "technogiq-discourse-invite-manager-manageinvites",
      { path: "manageinvites" }
    );

    
  },
};
