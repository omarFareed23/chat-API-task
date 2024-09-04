namespace :load_es_data do
  desc 'sync elasticsearch'
  task sync: :environment do
    unless Message.__elasticsearch__.client.indices.exists? index: Message.index_name
      puts "Elasticsearch index does not exist. Creating index and importing data..."
      Message.__elasticsearch__.create_index!
      Message.__elasticsearch__.import
    else
      puts "Elasticsearch index already exists. Skipping index creation."
    end
  end
end
