# frozen_string_literal: true

class CreateReservationFrames < ActiveRecord::Migration[6.0]
  def change
    create_table :reservation_frames do |t|
      t.string :availability_check_identifier, null: false
      t.string :park_name, null: false
      t.string :tennis_court_name, null: false
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.boolean :now, null: false
      t.integer :state, null: false, default: 0

      t.timestamps
    end
  end
end
