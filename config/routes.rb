FlindersAPI2::Application.routes.draw do
  namespace :api do
    resources :buildings do
      resources :rooms do
        resources :room_bookings, :path => "/bookings"
      end
    end
    resources :rooms
    resources :room_bookings, :path => "/bookings"
  end

  resources :broadcasts

  get '/signage/:id' => 'signage#view'
  get '/signage/:id/bookings' => 'signage#bookings'
  get '/signage/:id/news' => 'signage#news'

  get '/' => 'signage#view'
end
