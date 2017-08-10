Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'games/index'

  resources :games do
  	get :helperForms
  	post :status
  	get "status" => 'games#index'
  	post :join
  	get "join" => 'games#index'
  	post :check_moves
  	get "check_moves" => 'games#index'
  	post :move
  	get "move" => 'games#index'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'games#index'
end
