# Real-time Form Validation in Rails

## Demo

## Features

## Step 1: Initial Set Up

1. `rails new rails-real-time-form-validation --webpack=stimulus`
2. `rails g scaffold Post title body:text`
3. `rails db:migrate`

## Step 2: Add validations to Post Model

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  validates :body, length: { minimum: 10 }
  validates :title, presence: true
end
```
## Step 3: Create form validation endpoint

1. `rails g controller form_validations/posts`
2. Update controller to inherit from `PostsController`

```ruby
# app/controllers/form_validations/posts_controller.rb
class FormValidations::PostsController < PostsController
end
```

3. Create a namespaced route for the endpoints.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :posts
  namespace :form_validations do
    resources :posts, only: [:create, :update]
  end
end
```
