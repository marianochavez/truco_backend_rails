Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :games, only: [:index, :show, :create] do
        member do
          put 'join-game', as: :join_game
          put 'play-card', as: :play_card
          put 'leave'
          put 'deal'
        end
      end

      resources :players, only: [:index, :create] do
        collection do
          post 'sign-in', as: :sing_in
          post 'sign-out', as: :sign_out
        end
      end

    end
  end
end
