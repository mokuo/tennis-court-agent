# frozen_string_literal: true

class CreateAvailabilityChecks < ActiveRecord::Migration[6.0]
  def change
    create_table :availability_checks do |t|
      t.string :identifier, null: false

      t.timestamps
    end
    add_index :availability_checks, :identifier, unique: true
  end
end
