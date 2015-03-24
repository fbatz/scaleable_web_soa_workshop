require 'grape'

class ItemTrackingAPI < Grape::API

  # some default items are saved in items, because there is no DB
  # only for testing purpose
  items = [
    {
      "name": "Johannas PC",
      "location": 562,
      "id": 456
    },
    {
      "name": "Johannas desk",
      "location": 562,
      "id": 457
    },
    {
      "name": "Lobby chair #1",
      "location": 563,
      "id": 501
    }
  ]

  item_id = 0

  format :json

  # requires name and location id, they have to be part of the request
  params do
    requires :name, type: String, desc: "Your name."
    requires :location, type: Integer, desc: "Your location id."
  end
  post '/items' do
    # creates a new item element with a new id
    items.push({
      "name"=> params[:name],
      "location"=> params[:location],
      "id"=> item_id += 1
    })
    # returns HTTP status 201 with a complete JSON representation of the item (including the ID) 
    items.last
  end
  
  # returns status 200 and all items
  get '/items' do
    items
  end

  # DELETE Request
  delete '/items/(:id)' do
    # checks if the ID exists
    if items.find{|e| e['id'] == params[:id].to_i}
      # deletes the item specified by the ID
      items.delete_if{|e| e['id'] == params[:id].to_i}
      # returns status 200 and an empty body
      body false
    else
      # returns status 404 if the supplied ID does not exist.
      error!('404 ID does not exist.', 404)
    end
  end

end
