Rails.application.routes.draw do
  devise_for :users

  get '/auth/:provider/callback', to: 'sessions#create'
  
  authenticate do
  root 'artists#index'

    resource :artists, only: [:index]
  end
end
