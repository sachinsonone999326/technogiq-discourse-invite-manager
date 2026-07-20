# frozen_string_literal: true

class AddColumnInviteMetadata < ActiveRecord::Migration[7.0]
  def change
    add_column :invite_metadata, :renewal_period, :string, default: "monthly"
    add_column :invite_metadata, :renewal_period_value, :integer, default: 1
    add_column :invite_metadata, :is_batch_mode, :boolean, default: false
    add_column :invite_metadata, :number_of_invitations, :integer, default: 1
  end
end
