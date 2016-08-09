require "api_constraints"

Rails.application.routes.draw do
  devise_for :users

  namespace :api, defaults: {format: "json"} do
    devise_scope :user do
      post "sign_up", to: "registrations#create"
      post "sign_in", to: "sessions#create"
      delete "sign_out", to: "sessions#destroy"
      put "confirmation", to: "confirmations#update"
      get "pin", to: "pins#new"
      put "pin", to: "passwords#update"
      put "password", to: "passwords#update"
    end
    scope module: :v1, constraints: ApiConstraints.new(version: 1,
      default: true) do
      resources :users, only: [:update, :index]
      resources :invoices, only: :index
    end
  end
end
