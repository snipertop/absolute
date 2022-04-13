Rails.application.routes.draw do
  get 'student_user/index'
  get 'api/index'
  get 'api/sso'
  post 'message/msg'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "api#index"
end
