Rails.application.routes.draw do
  resources :posts
  namespace :posts do
    resources :form_validations
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
