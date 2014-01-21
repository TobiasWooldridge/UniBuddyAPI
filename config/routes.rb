FlindersAPI2::Application.routes.draw do
  namespace :api do
    namespace :v2 do
      get "/uni" => "institutions#index"
      get "/uni/:inst_code" => "institutions#show"

      get "/uni/:inst_code/topics" => "topics#index"
      get "/uni/:inst_code/topics/:topic_id" => "topics#show"
      get "/topics/:topic_id" => "topics#show"

      get "/uni/:inst_code/buildings" => "buildings#index"
      get "/uni/:inst_code/buildings/:building_code" => "buildings#show"
      get "/uni/:inst_code/buildings/:building_code/rooms" => "rooms#index"
      get "/uni/:inst_code/buildings/:building_code/rooms/:room_code" => "rooms#show"
      get "/uni/:inst_code/buildings/:building_code/rooms/:room_code/bookings" => "room_bookings#index"

      get "/uni/:inst_code/dates" => "dates#index"

      get "/uni/:inst_code/news" => "news#index"
    end
  end

  get '/signage/:id' => 'signage#view'
  get '/signage/:id/bookings' => 'signage#bookings'
  get '/signage/:id/news' => 'signage#news'

  get '/' => 'default#index'
end
