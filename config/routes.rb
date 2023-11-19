Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  resources :videos, only: [:new, :show]

  post 'videos/create', to: 'videos#create'
  post 'videos/update_video_details', to: 'videos#update_video_details'

  post 'mux', to: 'mux_webhooks#create'
  post '/transcription_callbacks', to: 'transcription_callbacks#create'

end
