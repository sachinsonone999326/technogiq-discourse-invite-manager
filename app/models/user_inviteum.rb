# frozen_string_literal: true

class UserIinviteum < ActiveRecord::Base
  self.table_name = "user_invited"

  belongs_to :invite
end
