class ChatWriter < ApplicationJob
  queue_as :default

  def perform(application_token, chat_number)
    @chat = Chat.new(application_token: application_token, number: chat_number)
    if @chat.save!
      REDIS.incr(Redis::RedisKeys::CHAT_NUMS_KEY % { application_token: application_token })
      REDIS.sadd(Redis::RedisKeys::UPDATED_APPLICATIONS_SET, application_token)
    end
  end

end
