# frozen_string_literal: true

class AddBatches < ActiveRecord::Migration[7.0]
  def change
    create_table :invite_batches do |t|
      t.integer  :batch_number, null: false
      t.integer  :created_by_id, null: false

      t.string   :description
      t.datetime :expires_at

      t.integer  :total_invites, default: 0
      t.integer  :redeemed_count, default: 0
      t.integer  :expired_count, default: 0

      t.timestamps
    end
  

    add_index :invite_batches, :batch_number, unique: true
    add_column :invite_metadata, :batch_id, :integer, default: 0

  end
end
