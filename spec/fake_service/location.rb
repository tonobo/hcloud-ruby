module Hcloud
  module FakeService
    $LOCATIONS = {
      'locations' => [
        {
          'id' => 1,
          'name' => 'fsn1',
          'description' => 'Falkenstein DC Park 1',
          'country' => 'DE',
          'city' => 'Falkenstein',
          'latitude' => 50.47612,
          'longitude' => 12.370071
        }, {
          'id' => 2,
          'name' => 'nbg1',
          'description' => 'Nuremberg DC Park 1',
          'country' => 'DE',
          'city' => 'Nuremberg',
          'latitude' => 49.452102,
          'longitude' => 11.076665
        }
      ],
      'meta' => {
        'pagination' => {
          'page' => 1,
          'per_page' => 25,
          'previous_page' => nil,
          'next_page' => nil,
          'last_page' => 1,
          'total_entries' => 2
        }
      }
    }

    class Location < Grape::API
      group :locations do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          get do
            x = $LOCATIONS['locations'].find { |x| x['id'] == params[:id] }
            error!({ error: { code: :not_found } }, 404) if x.nil?
            { location: x }
          end
        end

        params do
          optional :name, type: String
        end
        get do
          if params.key?(:name)
            dc = $LOCATIONS.deep_dup
            dc['locations'].select! { |x| x['name'] == params[:name] }
            dc
          else
            $LOCATIONS
          end
        end
      end
    end
  end
end
