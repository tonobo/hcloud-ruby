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
                @a = Action.resource_action('network', @x['id'], params[:aid])
                error!({ error: { code: :not_found } }, 404) if @x.nil?
              end
              get do
                { action: @a }
              end
            end

            params do
              optional :status, type: String
              optional :sort, type: String
            end
            get do
              actions = Action.resource_actions('network', @x['id'])
              unless params[:status].nil?
                actions['actions'].select! do |x|
                  x['status'].to_s == params[:status].to_s
                end
              end
              actions
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
            @x['name'] = params[:name] unless params[:name].nil?
            @x['labels'] = params[:labels] unless params[:labels].nil?
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

          # for tests set the last segment of the net range to 1 to create the gateway
          net = IPAddr.new(params[:ip_range])
          masklen = net.ipv6? ? 120 : 24
          gateway = (net.mask(masklen) | 1).to_s

          subnets = {}
          unless params[:subnets].nil?
            subnets = params[:subnets]
            subnets.each do |subnet|
              subnet[:gateway] = gateway
              subnet[:vswitch_id] = nil
            end
          end

          routes = params[:routes] || {}

          network = {
            'id' => $NETWORK_ID += 1,
            'name' => params[:name],
            'ip_range' => params[:ip_range],
            'subnets' => subnets,
            'routes' => routes,
            'labels' => params[:labels]
          }
          $NETWORKS['networks'] << network
          { network: network }
        end

        params do
          optional :name, type: String
        end
        get do
          networks = $NETWORKS.deep_dup
          networks['networks'].select! { |x| x['name'] == params[:name] } unless params[:name].nil?
          unless params[:label_selector].nil?
            networks['networks'].select! do |x|
              FakeService.label_selector_matches(params[:label_selector], x['labels'])
            end
          end

          networks
        end
      end
    end
  end
end
