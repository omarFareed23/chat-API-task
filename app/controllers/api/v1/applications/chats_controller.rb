class Api::V1::Applications::ChatsController < Api::BaseController
  before_action :find_application
  before_action :find_chat, only: [:destroy, :show]

  def index
    @chats = @application.chats
  end

  def create
    # @chat = @application.chats.new
    # @chat_number = REDIS.incr(Redis::RedisKeys::CHAT_COUNT_KEY % { application_token: @application.token })
    # @chat.number = @chat_number
    # unless @chat.save
    #   render json: @chat.errors, status: :unprocessable_entity
    # end
    @chat_number = REDIS.incr(Redis::RedisKeys::CHAT_COUNT_KEY % { application_token: @application.token })
    ChatWriter.perform_later(@application.token, @chat_number)
  end

  def destroy
    @chat.destroy!
    REDIS.decr(Redis::RedisKeys::CHAT_NUMS_KEY % { application_token: @application.token })
    REDIS.sadd(Redis::RedisKeys::UPDATED_APPLICATIONS_SET, @application.token)
    head :no_content
  end


  def show

  end

  private

  def find_chat
    @chat = @application.chats.find_by(number: params[:number])
    p @chat
    unless @chat
      render json: { error: 'Chat not found' }, status: :not_found
    end
  end

  def find_application
    p params
    @application = Application.find_by(token: params[:application_token])
    unless @application
      render json: { error: 'Application not found' }, status: :not_found
    end
  end
end
