# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :availability_check_identifier, null: false
      t.string :name, null: false
      t.datetime :published_at, null: false
      t.json :contents

      t.timestamps
    end
  end
end
