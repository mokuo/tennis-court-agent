# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  namespace :api, format: :json do
    resources :wakeup, only: [:create]
  end
end
