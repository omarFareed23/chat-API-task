json.array! @chats do |chat|
  json.partial! 'api/v1/models/chat', format: [:json], resource: chat
end
