# Chat API

## Description

This project is an API that enables the creation and management of applications and their associated chats and messages. Each application is identified by a unique token, allowing devices to send and receive chats. Chats are numbered sequentially within an application, and messages are similarly numbered within each chat. The system supports searching messages by content using ElasticSearch, while also handling high concurrency and ensuring optimized performance with count tracking for both chats and messages.

## Business Features

- Ability to create and manage multiple applications, each identified by a unique token.
- Applications can have multiple chats, each chat being uniquely identified by its number.
- Chats contain messages, and each message is uniquely identified by its number within the chat.
- Support for searching messages within a chat by matching content.
- Track the number of chats in each application and the number of messages in each chat.
- The system is designed to handle concurrent requests, making it suitable for high-traffic environments.

## Installation

Follow the steps below to set up and run the Chat API:

```sh
# Clone the repository
git clone https://github.com/omarFareed23/chat-API-task.git

# Navigate to the project directory
cd chat-API-task

# Build and start the containers
docker-compose up

# Run migrations to set up the database
docker-compose exec web bin/rails db:migrate
```

## Testing

### Setup the testing environment
```sh
# Create and load the test database
docker-compose exec web RAILS_ENV=test bin/rails db:create
docker-compose exec web RAILS_ENV=test bin/rails db:schema:load
```

### Run the test cases
```sh
docker-compose exec web bundle exec rspec
```