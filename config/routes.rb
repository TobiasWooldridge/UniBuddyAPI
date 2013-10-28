FlindersAPI2::Application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "/buildings" => "buildings#index"
      get "/buildings/:building_code" => "buildings#show"
      get "/buildings/:building_code/rooms" => "rooms#index"
      get "/buildings/:building_code/rooms/:room_code" => "rooms#show"
      get "/buildings/:building_code/rooms/:room_code/bookings" => "room_bookings#index"
      get "/dates" => "dates#index"
      get "/subjects" => "topics#subject_areas"
      get "/topics" => "topics#index"
      get "/topics/:unque_topic_code" => "topics#show"
      # get "/topics/:unque_topic_code/classes" => "topics#classes"
      get "/news" => "news#index"
    end
  end

  get '/signage/:id' => 'signage#view'
  get '/signage/:id/bookings' => 'signage#bookings'
  get '/signage/:id/news' => 'signage#news'

  get '/' => 'default#index'
end
