# frozen_string_literal: true

module Hcloud
  module FakeService
    $NETWORK_ID = 0
    $NETWORKS = {
      'networks' => [],
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

    class Network < Grape::API
      group :networks do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before_validation do
            @x = $NETWORKS['networks'].find { |x| x['id'].to_s == params[:id].to_s }
            error!({ error: { code: :not_found } }, 404) if @x.nil?
          end
          get do
            { network: @x }
          end

          group :actions do
            params do
              requires :aid, type: Integer
            end
            route_param :aid do
              before_validation do
                @a = $ACTIONS['actions'].find do |x|
                  (x['id'].to_s == params[:aid].to_s) &&
                    (x['resources'].to_a.any? do |y|
                      (y.to_h['type'] == 'network') && (y.to_h['id'] == @x['id'])
                    end)
                end
                error!({ error: { code: :not_found } }, 404) if @x.nil?
              end
              get do
                { action: @a }
              end
            end

            post :add_route do
              error!({ error: { code: :invalid_input } }, 400) if params[:gateway].nil?
              error!({ error: { code: :invalid_input } }, 400) if params[:destination].nil?

              @x['routes'] << {
                gateway: params[:gateway],
                destination: params[:destination]
              }

              a = Action.add(command: 'add_route', status: 'success',
                             resources: [{ id: @x['id'], type: 'network' }])
              { action: a }
            end

            post :delete_route do
              error!({ error: { code: :invalid_input } }, 400) if params[:gateway].nil?
              error!({ error: { code: :invalid_input } }, 400) if params[:destination].nil?

              @x['routes'].delete_if do |route|
                route[:gateway] == params[:gateway] && route[:destination] == params[:destination]
              end

              a = Action.add(command: 'delete_route', status: 'success',
                             resources: [{ id: @x['id'], type: 'network' }])
              { action: a }
            end

            post :add_subnet do
              error!({ error: { code: :invalid_input } }, 400) if params[:type].nil?
              error!({ error: { code: :invalid_input } }, 400) if params[:network_zone].nil?

              @x['subnets'] << {
                type: params[:type],
                network_zone: params[:network_zone],
                # IP range 10.0.0.0/24 might not match the actual sub net
                # but for unit tests should be OK. The real API allocates
                # a subnet that's inside the network IP range.
                ip_range: params[:ip_range] || '10.0.0.0/24'
              }

              a = Action.add(command: 'add_subnet', status: 'success',
                             resources: [{ id: @x['id'], type: 'network' }])
              { action: a }
            end

            post :delete_subnet do
              error!({ error: { code: :invalid_input } }, 400) if params[:ip_range].nil?

              @x['subnets'].delete_if { |subnet| subnet[:ip_range] == params[:ip_range] }

              a = Action.add(command: 'delete_subnet', status: 'success',
                             resources: [{ id: @x['id'], type: 'network' }])
              { action: a }
            end
          end

          params do
            optional :name, type: String
          end
          put do
            error!({ error: { code: :invalid_input } }, 400) if params[:name].nil?
            @x['name'] = params[:name]
            { network: @x }
          end

          delete do
            $NETWORKS['networks'].delete(@x)
            @body = nil
            status 204
          end
        end

        params do
          optional :name, type: String
          optional :ip_range, type: String
        end
        post do
          error!({ error: { code: :invalid_input } }, 400) if params[:name].nil?
          error!({ error: { code: :invalid_input } }, 400) if params[:ip_range].nil?
          if $NETWORKS['networks'].any? { |x| params[:name] == x['name'] }
            error!({ error: { code: :uniqueness_error } }, 400)
          end

          gateway = params[:ip_range].split('.')[1..3].join('.') + '.1'

          subnets = {}
          unless params[:subnets].nil?
            subnets = params[:subnets]
            subnets.each do |subnet|
              subnet[:gateway] = gateway
              subnet[:vswitch_id] = nil
            end
          end

          routes = {}
          routes = params[:routes] unless params[:routes].nil?

          network = {
            'id' => $NETWORK_ID += 1,
            'name' => params[:name],
            'ip_range' => params[:ip_range],
            'subnets' => params[:subnets],
            'routes' => params[:routes]
          }
          $NETWORKS['networks'] << network
          { network: network }
        end

        params do
          optional :name, type: String
        end
        get do
          if params.key?(:name)
            network = $NETWORKS.deep_dup
            network['networks'].select! { |x| x['name'] == params[:name] }
            network
          else
            $NETWORKS
          end
        end
      end
    end
  end
end
