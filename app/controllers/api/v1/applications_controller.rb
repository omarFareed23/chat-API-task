class Api::V1::ApplicationsController < Api::BaseController
  before_action :generate_random_token , only: [:create]
  before_action :find_application, only: [:show, :update, :destroy]

  def index
    @applications = Application.all
  end

  def create
    @application = Application.new(application_params)
    @application.token = @token
    if @application.save
      render json: @application, status: :created
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  def update
    if @application.update(application_params)
      render json: @application
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def application_params
    params.require(:application).permit(:name)
  end

  def generate_random_token
    @token = SecureRandom.hex(16)
  end

  def find_application
    @application = Application.find_by(token: params[:token])
    unless @application
      render json: { error: 'Application not found' }, status: :not_found
    end
  end
end
