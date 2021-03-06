# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :sponsors
  resources :rules
  resources :codes
  resources :platform_accounts
  resources :members
  resources :releases
  resources :platforms
  get '/', to: 'home#index'
  root 'home#index'
  get 'committee', to: 'home#committee'
  get 'lan', to: 'home#lan'
  get 'upcoming_events', to: 'home#upcoming_events'
  get 'sign_up', to: 'home#sign_up'
  get 'contact_us', to: 'home#contact_us'
  resources :game_event_relations
  resources :events do
    member do
      get ':facebook_event_id', to: 'events#new'
    end
  end
  resources :games
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
