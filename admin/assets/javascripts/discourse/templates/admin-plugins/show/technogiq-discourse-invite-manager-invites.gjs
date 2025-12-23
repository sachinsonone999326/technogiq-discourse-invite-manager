export default <template>
  <div class="admin-detail">
    <p><b>Invite Manager</b></p>

   <div>

     <form {{on "submit" (prevent-default this.submitInvite)}} class="invite-form">
  <div class="control-group">
    <label>Email</label>
    <input @value={{this.email}} @type="email" required />
  </div>

  <div class="control-group">
    <label>Expiration Date</label>
    <input @value={{this.expirationDate}} @type="date" />
  </div>

  <div class="control-group">
    <label>Plan</label>
    <input @value={{this.plan}} />
  </div>

  <div class="control-group">
    <label>Source</label>
    <input @value={{this.source}} />
  </div>

  <div class="control-group">
    <label>Campaign</label>
    <input @value={{this.campaign}} />
  </div>

  <button class="btn btn-primary" type="submit" disabled={{this.isSaving}}>
    {{#if this.isSaving}}Saving…{{else}}Create Invite{{/if}}
  </button>

  {{#if this.successMessage}}
    <p class="text-success">{{this.successMessage}}</p>
  {{/if}}

  {{#if this.errorMessage}}
    <p class="text-danger">{{this.errorMessage}}</p>
  {{/if}}
</form>

   </div>

   
  </div>
</template>;
