Rails.application.routes.draw do
  
  post 'signup', to: 'signup#do'
  post 'verify', to: 'signup#verify'
  
  get 'welcome/index'
  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
