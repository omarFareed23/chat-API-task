class MessageWriter < ApplicationJob
  queue_as :default

  def perform(chat, content, message_number)
    # byebug()
    # p chat
    # # return
    @message = Message.new(chat_id: chat.id, content: content, number: message_number)
    if @message.save!
      REDIS.incr(Redis::RedisKeys::MESSAGE_NUMS_KEY % { application_token: chat.application_token, chat_number: chat.number })
      REDIS.sadd(Redis::RedisKeys::UPDATED_CHATS_SET, chat.id)
    end
  end

end
