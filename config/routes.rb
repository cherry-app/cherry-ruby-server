Rails.application.routes.draw do
  
  post 'signup', to: 'signup#do'
  post 'verify', to: 'signup#verify'
  post 'resend_otp', to: 'signup#resend_otp'
  post 'sync_contacts', to: 'sync#contacts'
  post 'sync_blacklist', to: 'sync#blacklist'
  get 'professions', to: 'unauthenticated_sync#professions'
  
  post 'seen', to: 'message#seen'
  post 'message', to: 'message#publish'
  post 'fcm_token', to: 'message#update_fcm_token'

  get 'welcome/index'
  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
