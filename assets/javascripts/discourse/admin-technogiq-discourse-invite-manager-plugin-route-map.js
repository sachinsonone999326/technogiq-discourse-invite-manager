export default {
  resource: "admin.adminPlugins.show",

  path: "/plugins",

  map() {
    this.route(
      "technogiq-discourse-invite-manager-invites",
      { path: "invites" },
      function () {
        this.route("new");
        this.route("edit", { path: "/:id/edit" });
      }
    );
  },
};
