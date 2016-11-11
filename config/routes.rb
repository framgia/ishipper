require "api_constraints"

Rails.application.routes.draw do
  namespace :api, defaults: {format: "json"} do
    devise_scope :user do
      post "sign_up", to: "registrations#create"
      post "sign_in", to: "sessions#create"
      delete "sign_out", to: "sessions#destroy"
      get "confirmation", to: "confirmations#new"
      put "confirmation", to: "confirmations#update"
      get "password", to: "passwords#new"
      post "password", to: "passwords#create"
      put "password", to: "passwords#update"
      put "user_token", to: "user_tokens#update"
    end

    scope module: :v1, constraints: ApiConstraints.new(version: 1,
      default: true) do
      resources :users, only: [:show, :update, :index]
      resources :invoices, only: :index
      namespace :shipper do
        resources :invoices, only: [:update, :index, :show]
        resources :user_invoices, only: [:create, :destroy]
        resources :rates, only: [:create, :update, :destroy]
        resources :reports, only: :create
        resources :black_lists, only: [:create, :index, :destroy]
        resources :favorite_lists, only: [:create, :index, :destroy]
        resources :reviews, only: :index
        resources :destroy_all_black_lists, only: :index
        resources :destroy_all_favorite_lists, only: :index
        resources :notifications, only: [:index, :update]
      end
      namespace :shop do
        resources :invoices, except: [:edit, :new]
        resources :user_invoices, only: :update
        resources :list_shippers, only: :index
        resources :reports, only: [:create, :show]
        resources :rates, only: [:create, :update, :destroy]
        resources :black_lists, only: [:create, :index, :destroy]
        resources :favorite_lists, only: [:create, :index, :destroy]
        resources :reviews, only: :index
        resources :destroy_all_favorite_lists, only: :index
        resources :destroy_all_black_lists, only: :index
        resources :notifications, only: [:index, :update]
      end
    end
  end

  root "pages#index"
  get "/pages/:page", to: "pages#show"
  get "/invoices_pages/:status", to: "invoices_pages#show"

  devise_for :users, path: "", path_names: {sign_in: "login", sign_out: "logout"}
  devise_scope :user do
    post "sign_up", to: "registrations#create"
    get "sign_up", to: "registrations#new"
  end

  resources :feed_backs, only: [:new, :create]
  namespace :shop do
    resources :invoices
    resources :list_shippers, only: :index
  end

  scope do
    resources :users, path: "shops"
  end
end
