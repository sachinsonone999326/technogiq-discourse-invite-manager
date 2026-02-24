# frozen_string_literal: true

class AddRefInviteMetadataStructure < ActiveRecord::Migration[7.0]
  def change
    #  Add new columns
    add_column :invite_metadata, :uniqueid, :string
  end
end
