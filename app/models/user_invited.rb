# frozen_string_literal: true
#

class UserInvited < ActiveRecord::Base
  belongs_to :user
  belongs_to :invite
end
