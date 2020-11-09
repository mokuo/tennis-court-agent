# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.string :availability_check_identifier, null: false

      t.timestamps
    end

    add_index :notifications, :availability_check_identifier, unique: true
  end
end
