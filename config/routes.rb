Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :games, only: [:index, :show, :create] do
        member do
          put 'join-game', as: :join_game
          put 'play-card', as: :play_card
          put 'leave'
          put 'deal'
          put 'go-to-deck', as: :go_to_deck
          put 'burn-card', as: :burn_card
        end
      end

      resources :players, only: [:index, :create] do
        collection do
          post 'sign-in', as: :sing_in
          post 'sign-out', as: :sign_out
          patch 'avatar'
        end
      end

    end
  end
end
