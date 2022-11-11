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
