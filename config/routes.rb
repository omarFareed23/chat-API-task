Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      resources :applications, only: [:index, :create, :update, :show, :destroy], param: :token do
        scope module: :applications do
          resources :chats, only: [:index, :create, :show, :destroy], param: :number do
            scope module: :chats do
              resources :messages, only: [:index, :create, :show, :destroy], param: :message_number do
                collection do
                  get :search
                end
              end
            end
          end
        end
      end
    end
  end
end
