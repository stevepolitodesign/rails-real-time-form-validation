class Post < ApplicationRecord
  validates :body, length: { minimum: 10 }
  validates :title, presence: true
end
