class Application < ApplicationRecord
  has_many :chats, dependent: :destroy, foreign_key: 'application_token', primary_key: 'token'
end
