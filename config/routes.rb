Rails.application.routes.draw do
  root 'static_pages#home'
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  # resources :usersにネストを追加
  resources :users do
    # 以下でユーザーidが含まれるURLを扱えるようになる
    # memberメソッドを使うとユーザーidが含まれているURLを扱うようになる
    member do
      # :following, :followersのgetのルーティングを生成 
      get :following, :followers
    end
  end
  resources :users
  # account_activationsresourceのeditへのルーティングのみを生成
  resources :account_activations, only: [:edit] #リスト11.1 アカウント有効化に使うリソース（editアクション）を追加する
  #password_resetsのnew、create、edit、updateのルーティングを生成 
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  # relationshipsのcreateとdestroyのルーティングを生成
  resources :relationships,       only: [:create, :destroy]
end