class Chat < ApplicationRecord
  belongs_to :application, foreign_key: 'application_token', primary_key: 'token'
  has_many :messages
end
