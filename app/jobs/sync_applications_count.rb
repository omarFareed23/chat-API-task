class SyncApplicationsCount < ApplicationJob
  queue_as :default

  def perform
    application_tokens = REDIS.smembers(Redis::RedisKeys::UPDATED_APPLICATIONS_SET)

    application_tokens.each do |application_token|
      chat_count = nil

      REDIS.multi do |pipeline|
        chat_count = pipeline.get(Redis::RedisKeys::CHAT_NUMS_KEY % { application_token: application_token })
        pipeline.srem(Redis::RedisKeys::UPDATED_APPLICATIONS_SET, application_token)
      end
      chat_count = chat_count.value.to_i if chat_count
      application = Application.find_by(token: application_token)

      if application && chat_count
        application.update!(chats_count: chat_count)
      end
    end
  end
end
