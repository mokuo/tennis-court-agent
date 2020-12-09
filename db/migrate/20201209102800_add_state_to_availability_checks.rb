# frozen_string_literal: true

class AddStateToAvailabilityChecks < ActiveRecord::Migration[6.0]
  def change
    add_column :availability_checks, :state, :integer, default: 0
  end
end
