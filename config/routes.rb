Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      resources :applications, only: [:index, :create, :update, :show, :destroy], param: :token do
        scope module: :applications do
          resources :chats, only: [:index, :create, :show, :destroy], param: :chat_number
        end
      end
    end
  end
end
