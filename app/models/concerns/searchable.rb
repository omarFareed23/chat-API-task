module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # Specify the index name for ElasticSearch
    index_name "#{self.name.downcase}_index"

    # Define Elasticsearch settings for full-text search in the 'content' field
    settings index: {
      analysis: {
        analyzer: {
          custom_analyzer: {
            type: 'custom',
            tokenizer: 'standard',
            filter: %w[lowercase edge_ngram_filter]
          }
        },
        filter: {
          edge_ngram_filter: {
            type: 'edge_ngram',
            min_gram: 2,
            max_gram: 25
          }
        }
      }
    } do
      mappings dynamic: false do
        indexes :content, type: :text, analyzer: :custom_analyzer
        indexes :chat_id, type: :keyword # Use 'keyword' for exact matching
      end
    end
  end

  # Define class methods
  module ClassMethods
    def search2(chat_id, query)
      __elasticsearch__.search({
        query: {
          bool: {
            must: [
              {
                term: {
                  chat_id: chat_id # Exact matching on chat_id
                }
              },
              {
                multi_match: {
                  query: query,
                  fields: %w[content],
                  fuzziness: 'AUTO',
                  operator: 'and'
                }
              }
            ]
          }
        },
        sort: [
          {
            _score: {
              order: 'desc'
            }
          }
        ]
      })
    end
  end
end
