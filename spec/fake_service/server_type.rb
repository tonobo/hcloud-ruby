module Hcloud
  module FakeService
    $SERVER_TYPES = {
      'server_types' => [
        {
          'id' => 1,
          'name' => 'cx11',
          'description' => 'CX11',
          'cores' => 1,
          'memory' => 2.0,
          'disk' => 20,
          'prices' => [
            {
              'location' => 'fsn1',
              'price_hourly' => {
                'net' => '0.0040000000',
                'gross' => '0.0047600000000000'
              },
              'price_monthly' => {
                'net' => '2.4900000000',
                'gross' => '2.9631000000000000'
              }
            },
            {
              'location' => 'nbg1',
              'price_hourly' => {
                'net' => '0.0040000000',
                'gross' => '0.0047600000000000'
              },
              'price_monthly' => {
                'net' => '2.4900000000',
                'gross' => '2.9631000000000000'
              }
            }
          ],
          'storage_type' => 'local'
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

    class ServerType < Grape::API
      group :server_types do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          get do
            x = $SERVER_TYPES['server_types'].find { |x| x['id'] == params[:id] }
            error!({ error: { code: :not_found } }, 404) if x.nil?
            { server_type: x }
          end
        end

        params do
          optional :name, type: String
        end
        get do
          if params.key?(:name)
            dc = $SERVER_TYPES.deep_dup
            dc['server_types'].select! { |x| x['name'] == params[:name] }
            dc
          else
            $SERVER_TYPES
          end
        end
      end
    end
  end
end
