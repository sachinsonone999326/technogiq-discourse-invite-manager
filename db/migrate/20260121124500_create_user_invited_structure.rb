# frozen_string_literal: true
#

class CreateUserInvited < ActiveRecord::Migration[7.0]
  def change
    create_table :user_invited do |t|
      t.integer :user_id, null: false
      t.integer :invite_id, null: false
      t.jsonb :metadata, null: false, default: {}
      t.boolean :is_expiry_date, null: false, default: false
      t.datetime :expiration_date
      t.datetime :calculate_date
      t.string :plan_type
      t.integer :membership_duration_value
      t.timestamps
    end

    add_index :user_invited, :user_id, unique: true
  end
end
