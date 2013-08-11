FlindersAPI2::Application.routes.draw do
  resources :buildings
  
  resources :rooms do
    resources :room_bookings, :path => "/bookings", shallow: true
  end

  resources :broadcasts

  get '/signage/:id' => 'signage#view'
  get '/signage/:id/bookings' => 'signage#bookings'
  get '/signage/:id/news' => 'signage#news'
end
