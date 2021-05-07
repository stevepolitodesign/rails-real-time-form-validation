# Real-time Form Validation in Rails

## Demo

## Features

## Step 1: Initial Set Up

1. `rails new rails-real-time-form-validation --webpack=stimulus`
2. `rails g scaffold Post title body:text`
3. `rails db:migrate`

## Step 2: Add Validations to Post Model

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  validates :body, length: { minimum: 10 }
  validates :title, presence: true
end
```
## Step 3: Create Form Validation Endpoint

1. `rails g controller form_validations/posts`
2. Update controller to inherit from `PostsController`

```ruby
# app/controllers/form_validations/posts_controller.rb
class FormValidations::PostsController < PostsController
  def update
    @post.assign_attributes(post_params)
    @post.valid?
    respond_to do |format|
      format.json { render partial: 'posts/form', locals: { post: @post }, formats: [:html] } 
    end
  end
  
  def create
    @post = Post.new(post_params)
    @post.validate
    respond_to do |format|
      format.json { render partial: 'posts/form', locals: { post: @post }, formats: [:html] } 
    end
  end
end
```

**What's Going On?**

- We have access to `post_params` becuase we inherit from `PostsController`
- We call `assign_attributes` in the `update` action because we don't actually want to update the record. We just want to update the record in memory so that we can have it validated.
- We call `@post.valid?` and `@post.validate` in the `update` and `create` actions respectively to ensure any validation errors get sent to the partial.
- We only respond with JSON because we're hitting this endpoint with AJAX. We pass `formats: [:html]` to ensure the partial is rendered. Othwerwise Rails would looke for `_form.json.erb`.  

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

**What's Going On?**

- We don't have to namespace this controller, but it keeps things organized.

## Step 4: Create Stimulus Controller

1. `touch app/javascript/controllers/form_validation_controller.js` 

```js
// app/javascript/controllers/form_validation_controller.js
import Rails from "@rails/ujs"
import { Controller } from "stimulus"

export default class extends Controller {
  static targets  = [ "form", "output"]
  static values   = { url: String }

  handleChange(event) {
    let input = event.target
    Rails.ajax({
      url: this.urlValue,
      type: "POST",
      data: new FormData(this.formTarget),
      success: (data) => {
        this.outputTarget.innerHTML = data;
        input = document.getElementById(input.id);
      },
    })
  }

}
```

2. Update markup.

```html+erb
<%# app/views/posts/_form.html.erb %>
<%= form_with(model: post, data: { form_validation_target: "form" }) do |form| %>
  <% if post.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(post.errors.count, "error") %> prohibited this post from being saved:</h2>

      <ul>
        <% post.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= form.label :title %>
    <%= form.text_field :title, data: { action: "form-validation#handleChange" } %>
  </div>

  <div class="field">
    <%= form.label :body %>
    <%= form.text_area :body, data: { action: "form-validation#handleChange" } %>
  </div>

  <div class="actions">
    <%= form.submit disabled: post.errors.any?  %>
  </div>
<% end %>
```

```html+erb
<%# app/views/posts/new.html.erb %>
<h1>New Post</h1>

<div data-controller="form-validation" data-form-validation-target="output" data-form-validation-url-value="<%= form_validations_posts_path %>">
  <%= render 'form', post: @post %>
</div>

<%= link_to 'Back', posts_path %>
```

```html+erb
<%# app/views/posts/edit.html.erb %>
<h1>Editing Post</h1>

<div data-controller="form-validation" data-form-validation-target="output" data-form-validation-url-value="<%= form_validations_post_path(@post) %>">
  <%= render 'form', post: @post %>
</div>

<%= link_to 'Show', @post %> |
<%= link_to 'Back', posts_path %>
```

## Step 5: Debounce Requests

1. `yarn add lodash.debounce`

```js
// app/javascript/controllers/form_validation_controller.js
import Rails from "@rails/ujs"
import { Controller } from "stimulus"
const debounce = require('lodash.debounce');

export default class extends Controller {
  static targets  = [ "form", "output"]
  static values   = { url: String }

  initialize() {
    this.handleChange = debounce(this.handleChange, 500).bind(this)
  }

  handleChange(event) {
    let input = event.target
    Rails.ajax({
      url: this.urlValue,
      type: "POST",
      data: new FormData(this.formTarget),
      success: (data) => {
        this.outputTarget.innerHTML = data;
        input = document.getElementById(input.id);
      },
    })
  }
}
```

## Step 6: Focus Input

```js
import Rails from "@rails/ujs"
import { Controller } from "stimulus"
const debounce = require('lodash.debounce');

export default class extends Controller {
  static targets  = [ "form", "output"]
  static values   = { url: String }

  initialize() {
    this.handleChange = debounce(this.handleChange, 500).bind(this)
  }

  handleChange(event) {
    let input = event.target
    Rails.ajax({
      url: this.urlValue,
      type: "POST",
      data: new FormData(this.formTarget),
      success: (data) => {
        this.outputTarget.innerHTML = data;
        input = document.getElementById(input.id);
        this.moveCursorToEnd(input);
      },
    })
  }

  // https://css-tricks.com/snippets/javascript/move-cursor-to-end-of-input/
  moveCursorToEnd(element) {
    if (typeof element.selectionStart == "number") {
      element.focus();
      element.selectionStart = element.selectionEnd = element.value.length;
    } else if (typeof element.createTextRange != "undefined") {
      element.focus();
      var range = element.createTextRange();
      range.collapse(false);
      range.select();
    }
  }
}
```


