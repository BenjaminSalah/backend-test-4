Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'application#index'
  post '/answer' => 'application#answer'
  post '/menu' => 'application#menu'
  post '/status' => 'application#status'
  post '/recording' => 'application#recording'
  post '/recording_done' => 'application#recording_done'
end
