Rails.application.routes.draw do
  get 'student_user/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "api#index"
end
