Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  get '/auth/:provider/callback', to: 'sessions#create'
  
  authenticate do
  root 'artists#index'

    resource :artists, only: [:index]
  end
end
