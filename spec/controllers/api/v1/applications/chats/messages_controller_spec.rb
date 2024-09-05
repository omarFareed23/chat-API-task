RSpec.describe 'Messages Controller', type: :request do
  let!(:application) { Application.create!(name: Faker::App.name, token: SecureRandom.hex(16)) }
  let!(:chat) { Chat.create!(application: application, number: 1) }
  let!(:message) { Message.create!(chat: chat, content: 'Test message', number: 1) }
  let(:default_headers) { { 'ACCEPT' => 'application/json' } }

  before do
    @mock_redis = MockRedis.new
    @mock_redis.set('message_number', 0)
    allow(REDIS).to receive(:incr) do
      @mock_redis.incr('message_number')
    end
    allow(REDIS).to receive(:decr) do
      @mock_redis.decr('message_number')
    end
    allow(REDIS).to receive(:sadd)
  end

  describe 'GET #index' do
    it 'returns all messages for the chat' do
      get "/api/v1/applications/#{application.token}/chats/#{chat.number}/messages", headers: default_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1) # since we created one message
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { message: { content: 'New message' } } }

    it 'increments the message number in Redis' do
      expect {
        post "/api/v1/applications/#{application.token}/chats/#{chat.number}/messages", params: valid_params, headers: default_headers
      }.to change { @mock_redis.get('message_number').to_i }.by(1)
    end

    it 'calls the MessageWriter job' do
      expect(MessageWriter).to receive(:perform_later).with(chat, 'New message', @mock_redis.get('message_number').to_i + 1)
      post "/api/v1/applications/#{application.token}/chats/#{chat.number}/messages", params: valid_params, headers: default_headers
    end
  end

  describe 'GET #show' do
    it 'returns the message if it exists' do
      get "/api/v1/applications/#{application.token}/chats/#{chat.number}/messages/#{message.number}", headers: default_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['content']).to eq(message.content)
    end

    it 'returns an error if the message does not exist' do
      get "/api/v1/applications/#{application.token}/chats/#{chat.number}/messages/999", headers: default_headers

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Message not found')
    end
  end

  describe 'DELETE #destroy' do
    it 'decrements the message number in Redis' do
      expect {
        delete "/api/v1/applications/#{application.token}/chats/#{chat.number}/messages/#{message.number}", headers: default_headers
      }.to change { @mock_redis.get('message_number').to_i }.by(-1)
    end

    it 'destroys the message' do
      expect {
        delete "/api/v1/applications/#{application.token}/chats/#{chat.number}/messages/#{message.number}", headers: default_headers
      }.to change { chat.messages.count }.by(-1)
    end

    it 'returns no content status' do
      delete "/api/v1/applications/#{application.token}/chats/#{chat.number}/messages/#{message.number}", headers: default_headers
      expect(response).to have_http_status(:no_content)
    end

    it 'adds the chat ID to the Redis set' do
      expect(REDIS).to receive(:sadd).with(Redis::RedisKeys::UPDATED_CHATS_SET, chat.id)
      delete "/api/v1/applications/#{application.token}/chats/#{chat.number}/messages/#{message.number}", headers: default_headers
    end
  end

  describe 'GET #search' do
    it 'returns search results when query is present' do
      allow(Message).to receive(:search2).and_return([message])
      get "/api/v1/applications/#{application.token}/chats/#{chat.number}/messages/search", params: { query: 'Test' }, headers: default_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
    end


    it 'returns an error if no query is provided' do
      get "/api/v1/applications/#{application.token}/chats/#{chat.number}/messages/search", params: { query: '' }, headers: default_headers

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['error']).to eq('No query provided')
    end
  end
end
