module Redis::RedisKeys
  CHAT_COUNT_KEY = 'CHAT_COUNT:%<application_token>s'.freeze
  MESSAGE_COUNT_KEY = 'MESSAGE_COUNT:%<application_token>s:%<chat_number>d'.freeze
  CHAT_NUMS_KEY = 'CHAT_NUMS:%<application_token>s'.freeze
  MESSAGE_NUMS_KEY = 'MESSAGE_NUMS:%<application_token>s:%<chat_number>d'.freeze
  UPDATED_APPLICATIONS_SET = 'UPDATED_APPLICATIONS_SET'.freeze
  UPDATED_CHATS_SET = 'UPDATED_CHATS_SET'.freeze
end
