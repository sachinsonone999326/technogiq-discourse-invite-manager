# frozen_string_literal: true

class UpgradeInviteMetadataStructure < ActiveRecord::Migration[7.0]
  def change
    #  Add new columns
    add_column :invite_metadata, :metadata, :jsonb, null: false, default: {}
    add_column :invite_metadata, :is_expiry_date, :boolean, null: false, default: false
    add_column :invite_metadata, :plan_type, :string
    add_column :invite_metadata, :membership_duration_value, :integer

    #  Keep expiration_date (already exists)

    #  Remove old key/value columns
    remove_index :invite_metadata, column: [:invite_id, :key]
    remove_column :invite_metadata, :key
    remove_column :invite_metadata, :value

    #  New index
    add_index :invite_metadata, :invite_id
  end
end
