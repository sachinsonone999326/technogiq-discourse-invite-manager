# frozen_string_literal: true

class InviteMetadatum < ActiveRecord::Base
  self.table_name = "invite_metadata"

  belongs_to :invite
end
