# frozen_string_literal: true

module Yokohama
  class JobDispatchService
    def dispatch_available_dates_jobs(park_names)
      park_names.each { |park_name| AvailableDatesJob.perform_later(park_name) }
    end
  end
end
