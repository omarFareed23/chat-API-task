class Message < ApplicationRecord
  # include Searchable
  belongs_to :chat

  include Searchable
  #   # Elasticsearch Mapping
  # settings @@elastic_search_settings do
  #   mappings dynamic: false do
  #     indexes :id, type: :integer, index: false
  #     # indexes :application_token, type: :keyword
  #     indexes :chat_id, type: :number
  #     indexes :number, type: :integer, index: false
  #     indexes :token, type: :text, analyzer: :custom_analyzer
  #     indexes :created_at, type: :date, index: false
  #     indexes :updated_at, type: :date, index: false
  #     indexes :content, type: :text, analyzer: :text_analyzer
  #   end
  # end

  # def self._search(chat_id, query)

  #   p query
  #   p chat_id
  #   val = search({ query: {
  #            bool: {
  #              must: [{ match: { content: query } }],
  #              filter: [
  #                { term: { chat_id: chat_id } },
  #               #  { term: { chat_number: chat_number } }
  #              ]
  #            }
  #          } })
  #   byebug
  #   p val.records
  #   val

  # end
  # # private

end
