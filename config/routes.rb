Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: "sessions"
  }

  authenticated do
    root 'favorites#index', as: :authenticated_root
  end
  unauthenticated do
    root 'pages#show', page: 'welcome', as: :unauthenticated_root
  end

  get "/pages/:page" => "pages#show"

  authenticate do
    resources :favorites, only: [:index]
  end

  resources :artists, only: [:show]
end
