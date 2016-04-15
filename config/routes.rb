Rails.application.routes.draw do
  devise_for :users
  
  authenticate do
  root 'artists#index'

    resource :artists, only: [:index]
  end
end
