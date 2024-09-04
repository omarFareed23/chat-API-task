class SyncChatsCount < ApplicationJob
  queue_as :default

  def perform
    print 'entered\n'
    chat_ids = REDIS.smembers(Redis::RedisKeys::UPDATED_CHATS_SET)
    chat_ids.each do |chat_id|
      chat = Chat.find_by(id: chat_id)
      next unless chat
      message_count = nil
      REDIS.multi do |pipeline|
        message_count = pipeline.get(Redis::RedisKeys::MESSAGE_NUMS_KEY % { application_token: chat.application_token, chat_number: chat.number })
        pipeline.srem(Redis::RedisKeys::UPDATED_CHATS_SET, chat_id)
      end

      message_count = message_count.value.to_i if message_count
      chat.update!(messages_count: message_count) if chat && message_count
    end
  end
end
