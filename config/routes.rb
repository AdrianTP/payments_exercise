Rails.application.routes.draw do
  resources :loans, defaults: {format: :json} do
    resources :payments, defaults: {format: :json}, only: [:index, :create]
  end

  resources :payments, defaults: {format: :json}, only: [:show]
end
