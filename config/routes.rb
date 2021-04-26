Rails.application.routes.draw do
  resources :posts
  namespace :form_validations do
    resources :posts, only: [:create, :update]
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
