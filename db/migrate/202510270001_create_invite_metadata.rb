class CreateInviteMetadata < ActiveRecord::Migration[6.1]
  def change
    create_table :invite_metadata do |t|
      t.integer :invite_id, null: false
      t.string :key, null: false
      t.text :value
      t.timestamps
    end
    add_index :invite_metadata, [:invite_id, :key], unique: true
  end
end

