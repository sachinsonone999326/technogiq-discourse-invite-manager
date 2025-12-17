export default {
  resource: "admin.adminPlugins.show",
  path: "/plugins",
  map() {
    this.route(
      "discourse-technogiq-discourse-invite-manager",
      { path: "invite-manager" },
      function () {
        this.route("new");
      }
    );
  },
};
