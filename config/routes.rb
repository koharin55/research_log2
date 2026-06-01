Rails.application.routes.draw do
  devise_for :users

  root "home#index"
  # get "/home", to: "home#index"

  resources :logs do
    member do
      patch :toggle_pin  # ピン留めのオン/オフ用
      post  :increment_copy_count  # Copyボタン押下時にコピー回数を +1 する用（JSから叩く）
    end
  end

  resources :categories, only: [:index, :create, :edit, :update, :destroy]
end
