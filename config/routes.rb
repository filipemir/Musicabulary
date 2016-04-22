Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: "sessions"
  }

  root 'pages#show', page: 'welcome'

  get "/pages/:page" => "pages#show"

  authenticate do
    resources :artists, only: [:index]
  end
end
