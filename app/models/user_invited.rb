# frozen_string_literal: true
#

class UserInvited < ActiveRecord::Base
  belongs_to :user
  belongs_to :invite

  validates :invite_id, presence: true
  validates :metadata, presence: true
  validates :user_id, presence: true
  
end
