Rails.application.routes.draw do
  get "up", to: "rails/health#show", as: :rails_health_check

  # Payment routes
  resource :payment, only: [] do
    collection do
      get :checkout
      post :checkout
      get :success
    end
  end
end
