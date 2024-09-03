json.array! @applications do |application|
  json.partial! 'api/v1/models/application', format: [:json], resource: application
end
