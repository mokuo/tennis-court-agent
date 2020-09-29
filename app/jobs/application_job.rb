# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  def self.perform_jobs_later(event)
    path = event.path
    path.children.each do |child|
      perform_later(path.append(child))
    end
  end
end
