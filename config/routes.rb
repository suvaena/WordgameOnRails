Rails.application.routes.draw do
  root 'game#new'
  get 'game/win'
  get 'game/lose'
  get 'game/show'
  get 'game/new'
  post 'game/create'
  post 'game/guess'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
