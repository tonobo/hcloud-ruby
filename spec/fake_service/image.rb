module Hcloud
  module FakeService
    $IMAGES = {
      'images' => [
        {
          'id' => 1,
          'type' => 'system',
          'status' => 'available',
          'name' => 'ubuntu-16.04',
          'description' => 'Ubuntu 16.04',
          'image_size' => nil,
          'disk_size' => 5,
          'created' => '2018-01-15T11:34:45+00:00',
          'created_from' => nil,
          'bound_to' => nil,
          'os_flavor' => 'ubuntu',
          'os_version' => '16.04',
          'rapid_deploy' => true,
          'deprecated' => '2018-02-28T00:00:00+00:00'
        },
        {
          'id' => 3454,
          'type' => 'snapshot',
          'status' => 'available',
          'name' => nil,
          'description' => 'snapshot image created at 2018-02-02 10:28:21',
          'image_size' => 0.64352086328125,
          'disk_size' => 20,
          'created' => '2018-02-02T10:28:21+00:00',
          'created_from' => { 'id' => 497_533, 'name' => 'moo5' },
          'bound_to' => nil,
          'os_flavor' => 'ubuntu',
          'os_version' => nil,
          'rapid_deploy' => false,
          'deprecated' => nil
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

    class Image < Grape::API
      group :images do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before_validation do
            @x = $IMAGES['images'].find { |x| x['id'].to_s == params[:id].to_s }
            error!({ error: { code: :not_found } }, 404) if @x.nil?
          end
          get do
            { image: @x }
          end

          params do
            optional :description, type: String
            optional :type, type: String
          end
          put do
            if !params[:description].nil? && @x['id'] != 3454
              error!({ error: { code: :not_found } }, 404) if @x.nil?
            end
            if !params[:type].nil? && @x['id'] != 3454
              if %w[backup system snapshot].include?(params[:type])
                error!({ error: { code: :not_found } }, 400)
              else
                error!({ error: { code: :invalid_input } }, 400)
              end
            end
            case params[:type]
            when 'system'
              error!({ error: { code: :service_error } }, 400)
            when 'backup'
              error!({ error: { code: :service_error } }, 400)
            end
            @x['description'] = params[:description] unless params[:description].nil?
            @x['type'] = params[:type] unless params[:type].nil?
            { image: @x }
          end

          delete do
            $IMAGES['images'].delete(@x)
            ''
          end
        end

        params do
          optional :name, type: String
          optional :type, type: String
          optional :bound_to, type: String
        end
        get do
          dc = $IMAGES.deep_dup
          dc['images'].select! { |x| x['name'] == params[:name] } unless params[:name].nil?
          dc['images'].select! { |x| x['type'] == params[:type] } unless params[:type].nil?
          unless params[:bound_to].nil?
            dc['images'].select! { |x| x['bound_to'].to_s == params[:bound_to].to_s }
          end
          dc
        end
      end
    end
  end
end
