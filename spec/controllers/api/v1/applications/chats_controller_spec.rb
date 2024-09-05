require 'rails_helper'
RSpec.describe 'Chats Controller', type: :request do
  let!(:application) { Application.create!(name: Faker::App.name, token: SecureRandom.hex(16)) }
  let(:default_headers) { { 'ACCEPT' => 'application/json' } }

  before do
    @mock_redis = MockRedis.new
    @mock_redis.set('chat_number', 0)
    allow(REDIS).to receive(:incr) do
      @mock_redis.incr('chat_number')
    end
    allow(REDIS).to receive(:decr) do
      @mock_redis.decr('chat_number')
    end
    allow(REDIS).to receive(:sadd)
  end

  describe 'POST #create' do
    it 'increments the chat number in Redis' do
      expect {
        post "/api/v1/applications/#{application.token}/chats", params: { application_token: application.token }, headers: default_headers
      }.to change { @mock_redis.get('chat_number').to_i }.by(1)
    end

    it 'calls the ChatWriter job' do
      expect(ChatWriter).to receive(:perform_later).with(application.token, @mock_redis.get('chat_number').to_i + 1)
      post "/api/v1/applications/#{application.token}/chats", params: { application_token: application.token }, headers: default_headers
    end
  end

  describe 'GET #show' do
    let!(:chat) { application.chats.create!(number: 1) }

    it 'returns the chat if it exists' do
      get "/api/v1/applications/#{application.token}/chats/#{chat.number}", headers: default_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['chat_number']).to eq(chat.number)
    end

    it 'returns an error if the chat does not exist' do
      get "/api/v1/applications/#{application.token}/chats/999", headers: default_headers

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Chat not found')
    end
  end

  describe 'DELETE #destroy' do
    let!(:chat) { application.chats.create!(number: 1) }

    it 'decrements the chat number in Redis' do
      expect {
        delete "/api/v1/applications/#{application.token}/chats/#{chat.number}", headers: default_headers
      }.to change { @mock_redis.get('chat_number').to_i }.by(-1)
    end

    it 'destroys the chat' do
      expect {
        delete "/api/v1/applications/#{application.token}/chats/#{chat.number}", headers: default_headers
      }.to change { application.chats.count }.by(-1)
    end

    it 'returns no content status' do
      delete "/api/v1/applications/#{application.token}/chats/#{chat.number}", headers: default_headers
      expect(response).to have_http_status(:no_content)
    end

    it 'adds the application token to the Redis set' do
      expect(REDIS).to receive(:sadd).with(Redis::RedisKeys::UPDATED_APPLICATIONS_SET, application.token)
      delete "/api/v1/applications/#{application.token}/chats/#{chat.number}", headers: default_headers
    end
  end

  describe 'GET #index' do
    before do
      # Manually create chats
      3.times { Chat.create!(application: application, number: @mock_redis.incr('chat_number')) }
    end

    it 'returns all chats for the application' do
      get "/api/v1/applications/#{application.token}/chats", headers: default_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

end
