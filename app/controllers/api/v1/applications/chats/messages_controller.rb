class Api::V1::Applications::Chats::MessagesController < Api::BaseController
  before_action :find_chat
  before_action :find_message, only: [:destroy, :show]

  def index
    @messages = @chat.messages
  end

  def create
    # @message = @chat.messages.new(message_params)
    # @message_number = REDIS.incr(Redis::RedisKeys::MESSAGE_COUNT_KEY % { application_token: @chat.application_token, chat_number: @chat.number })
    # @message.number = @message_number
    # p @message
    # unless @message.save
    #   render json: @message.errors, status: :unprocessable_entity
    # end
    @message_number = REDIS.incr(Redis::RedisKeys::MESSAGE_COUNT_KEY % { application_token: @chat.application_token, chat_number: @chat.number })
    MessageWriter.perform_later(@chat, message_params[:content], @message_number)
  end

  def destroy
    @message.destroy!
    REDIS.decr(Redis::RedisKeys::MESSAGE_NUMS_KEY % { application_token: @chat.application_token, chat_number: @chat.number })
    REDIS.sadd(Redis::RedisKeys::UPDATED_CHATS_SET, @chat.id)
    head :no_content
  end


  def show

  end

  def search
    if params[:query].present?
      # p params[:query]
      # byebug
      @messages = Message.search2(@chat.id, params[:query])
      render json: @messages.results
    else
      render json: { error: 'No query provided' }, status: :bad_request
    end
  end

  private

  def find_message
    @message = @chat.messages.find_by(number: params[:message_number])
    unless @message
      render json: { error: 'Message not found' }, status: :not_found
    end
  end

  def find_chat
    p params
    @chat = Chat.find_by(number: params[:chat_number], application_token: params[:application_token])
    unless @chat
      render json: { error: 'Chat not found' }, status: :not_found
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
