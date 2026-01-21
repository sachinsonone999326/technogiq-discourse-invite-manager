# frozen_string_literal: true

class UserInviteum < ActiveRecord::Base
  self.table_name = "user_invited"

  belongs_to :invite
  belongs_to :user
end
