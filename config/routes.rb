StitchRequest::Application.routes.draw do
  resources :requests

  # root index
  root to: 'requests#new'
end
