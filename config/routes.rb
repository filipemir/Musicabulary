Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: "sessions"
  }

  authenticated do
    root 'artists#index', as: :authentictaed_root
  end
  unauthenticated do
    root 'pages#show', page: 'welcome', as: :unauthenticated_root
  end

  get "/pages/:page" => "pages#show"

  authenticate do
    resources :artists, only: [:index]
  end

end
