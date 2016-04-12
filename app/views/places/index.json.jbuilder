json.array!(@places) do |place|
  json.extract! place, :id, :name, :description, :address, :zipcode, :city, :user_id, :area
  json.url place_url(place, format: :json)
end
