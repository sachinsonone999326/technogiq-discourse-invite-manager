export default {
  resource: "admin.adminPlugins.show",

  path: "/plugins",

  map() {
    this.route(
      "invite-manager",

      function () {
        this.route("new");
        this.route("edit", { path: "/:id" });
      }
    );
  },
};

