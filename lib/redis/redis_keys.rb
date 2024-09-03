module Redis::RedisKeys
  CHAT_COUNT_KEY = 'CHAT_COUNT:%<application_token>s'.freeze
  MESSAGE_COUNT_KEY = 'MESSAGE_COUNT:%<application_token>s:%<chat_number>d'.freeze
end
