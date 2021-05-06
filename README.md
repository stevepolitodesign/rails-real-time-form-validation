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
