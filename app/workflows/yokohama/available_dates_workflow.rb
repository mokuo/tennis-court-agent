# frozen_string_literal: true

module Yokohama
  class AvailableDatesWorkflow < Gush::Workflow
    def configure(park_names)
      park_names.map do |park_name|
        run AvailableDatesJob, params: { park_name: park_name }
      end
    end
  end
end
