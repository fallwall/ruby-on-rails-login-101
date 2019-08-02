Rails.application.routes.draw do
  root 'sessions#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users do
    resources :posts
  end

  #resources :sessions, only: [:create, :new, :destoy]
    get '/logout', to: 'sessions#destroy'
    get '/login', to: 'sessions#new'
    post '/login' => 'sessions#create'
    #this is how to write out your own url
end
