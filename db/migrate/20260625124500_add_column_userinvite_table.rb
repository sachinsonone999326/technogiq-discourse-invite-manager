# frozen_string_literal: true

class AddColumnUserinviteTable < ActiveRecord::Migration[7.0]
  def change
    add_column :user_invited, :renewal_period, :string, default: "monthly"
    add_column :user_invited, :renewal_period_value, :integer, default: 1
    add_column :user_invited, :is_batch_mode, :boolean, default: false
    add_column :user_invited, :batch_id, :integer, default: 0
  end
end
