FlindersAPI2::Application.routes.draw do
  resources :buildings
  
  resources :rooms do
    resources :room_bookings, :path => "/bookings", shallow: true
  end

  match '/signage/:id' => 'signage#view', via: [:get]
end
