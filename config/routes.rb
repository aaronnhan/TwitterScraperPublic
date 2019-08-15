Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'application#home_screen'
  get '/search', to: 'application#search'
  get '/home_screen', to: 'application#home_screen'
end
