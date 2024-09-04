class Application < ApplicationRecord
  has_many :chats, dependent: :destroy, foreign_key: 'application_token', primary_key: 'token'
  validates :name, presence: true
  validates :token, presence: true
end
