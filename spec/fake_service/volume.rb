# frozen_string_literal: true

module Hcloud
  module FakeService
    $VOLUME_ID = 0
    $VOLUMES = {
      'volumes' => [],
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

    class Volume < Grape::API
      group :volumes do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before_validation do
            @x = $VOLUMES['volumes'].find { |x| x['id'].to_s == params[:id].to_s }
            error!({ error: { code: :not_found } }, 404) if @x.nil?
          end
          get do
            { volume: @x }
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
                      (y.to_h['type'] == 'volume') && (y.to_h['id'] == @x['id'])
                    end)
                end
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
              dc = $ACTIONS.deep_dup
              dc['actions'].select! do |x|
                x['resources'].to_a.any? do |y|
                  (y.to_h['type'] == 'volume') && (y.to_h['id'].to_s == @x['id'].to_s)
                end
              end
              unless params[:status].nil?
                dc['actions'].select! do |x|
                  x['status'].to_s == params[:status].to_s
                end
              end
              dc
            end

            helpers do
              def locked?
                a = $ACTIONS['actions'].select do |x|
                  x['resources'].to_a.any? do |y|
                    (y.to_h['type'] == 'volume') && (y.to_h['id'] == @x['id'])
                  end
                end
                a.to_a.any? { |x| x['status'] == 'running' }
              end
            end

            params do
              optional :name, type: String
            end
            put do
              error!({ error: { code: :invalid_input } }, 400) if params[:name].nil?
              if $VOLUMES['volumes'].any? { |x| x['name'] == params[:name] }
                error!({ error: { code: :uniqueness_error } }, 400)
              end
              @x['name'] = params[:name]
              { volume: @x }
            end

            delete do
              $VOLUMES['volumes'].delete(@x)
              { action: Action.add(status: 'success', command: 'delete_volume',
                                   resources: [{ id: @x['id'], type: 'volume' }]) }
            end
          end

          params do
            requires :name, type: String
            requires :size, type: Integer

            optional :location, type: String
            optional :automount, type: Boolean
            optional :format, type: String
            optional :server, type: Integer
          end
          post do
            if $VOLUMES['volumes'].any? { |x| x['name'] == params[:name] }
              error!({ error: { code: :uniqueness_error } }, 400)
            end
            if !params[:location].nil? &&
               $LOCATIONS['locations'].none? do |x|
                 [x['id'].to_s, x['name']].include?(params[:location].to_s)
               end
              error!({ error: { code: :invalid_input, message: 'invalid location' } }, 400)
            end
            unless %w[xfs ext4].include(params[:format])
              error!({ error: { code: :invalid_input, message: 'invalid format' } }, 400)
            end
            id = $VOLUME_ID += 1
            v = {
              volume: {
                id: id,
                name: params[:name],
                created: Time.now.iso8601,
                format: params[:format],
                location: params[:location],
                protection: {
                  delete: false
                },
                linux_device: "/dev/disk/by-id/scsi-0HC_Volume_#{id}",
                server: params[:server],
                status: 'creating'
              },
              action: Action.add(
                status: 'running',
                command: 'create_volume',
                resources: [{ id: id, type: 'volume' }]
              )
            }.deep_stringify_keys
            $VOLUMES['volumes'] << v['volume']
            Thread.new do
              sleep(0.5)
              v['volume']['status'] = 'available'
              $ACTIONS['actions'].find { |x| x['id'] == s['action']['id'] }['status'] = 'available'
            end
            v
          end

          params do
            optional :name, type: String
          end
          get do
            dc = $VOLUMES.deep_dup
            dc['volumes'].select! { |x| x['name'] == params[:name] } unless params[:name].nil?
            dc
          end
        end
      end
    end
  end
end
