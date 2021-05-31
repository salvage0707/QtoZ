Rails.application.routes.draw do
  root to: 'home#index'

  # 利用規約
  get 'terms', to: "home#terms"
  
  # プライバシーポリシー
  get 'privacy', to: "home#privacy"

  devise_for :users, skip: [:registration, :session, :password], controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get    '/users/sign_in',  to: 'devise/sessions#new',     as: :new_user_session
    get    '/users/sign_up',  to: 'home#index',              as: :new_user_registration
    delete '/users/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  resources :articles, only: [:index, :new, :create, :destroy, :update]

  get  'zip/jobs', to: 'zip#index',  as: :zip_jobs
  post 'zip/jobs', to: 'zip#create'
end
