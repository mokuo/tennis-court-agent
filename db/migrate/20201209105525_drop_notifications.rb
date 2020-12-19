# frozen_string_literal: true

class DropNotifications < ActiveRecord::Migration[6.0]
  def up
    drop_table :notifications
  end

  def down
    create_table :notifications do |t|
      t.string :availability_check_identifier, null: false

      t.timestamps
    end

    add_index :notifications, :availability_check_identifier, unique: true
  end
end
