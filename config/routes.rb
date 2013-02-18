Campaings::Application.routes.draw do
  root :to => 'campaings#index'
  resources :campaings
end
