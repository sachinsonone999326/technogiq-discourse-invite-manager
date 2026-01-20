# frozen_string_literal: true
#

class CreateInviteMetadata < ActiveRecord::Migration[7.0]
  def change
    create_table :invite_metadata do |t|
      t.integer :invite_id, null: false
      t.jsonb :metadata, null: false, default: {}
      t.boolean :is_expiry_date, null: false, default: false
      t.datetime :expiration_date
      t.string :plan_type
      t.integer :membership_duration_value
      t.timestamps
    end

    add_index :invite_metadata, [:invite_id, :key], unique: true
  end
end
