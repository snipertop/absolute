Rails.application.routes.draw do
  resources :modify_mobiles do
    collection do
      get :complete, :callback, :auth
    end
  end
  resources :scores do 
    collection do
      post :search
    end
  end
  get 'student_user/index'  #学生基本信息同步
  get 'api/index'
  get 'api/sso'
  post 'message/msg'  #简道云消息到一网通办
  get 'wexin_user/index'
  get 'wexin_user/show'
  post 'wexin_user/search'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "api#index"
end
