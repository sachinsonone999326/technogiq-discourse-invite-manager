class InviteMetadata < ActiveRecord::Base
  belongs_to :invite
  validates :invite_id, :key, presence: true
end
