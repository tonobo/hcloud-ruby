# frozen_string_literal: true

module Hcloud
  module FakeService
    $SERVER_ID = 0
    $SERVERS = {
      'servers' => [],
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

    class Server < Grape::API
      group :servers do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before_validation do
            @x = $SERVERS['servers'].find { |x| x['id'].to_s == params[:id].to_s }
            error!({ error: { code: :not_found } }, 404) if @x.nil?
          end
          get do
            { server: @x }
          end

          group :actions do
            params do
              requires :aid, type: Integer
            end
            route_param :aid do
              before_validation do
                @a = Action.resource_action('server', @x['id'], params[:aid])
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
              actions = Action.resource_actions('server', @x['id'])
              unless params[:status].nil?
                actions['actions'].select! do |x|
                  x['status'].to_s == params[:status].to_s
                end
              end
              actions
            end

            helpers do
              def locked?
                a = Action.resource_actions('server', @x['id'])['actions']
                a.to_a.any? { |x| x['status'] == 'running' }
              end
            end

            post :poweron do
              error!({ error: { code: :locked } }, 400) if locked?
              a = Action.add(command: 'start_server', status: 'running',
                             resources: [{ id: @x['id'], type: 'server' }])
              Thread.new do
                sleep(0.5)
                @x['status'] = 'running'
                $ACTIONS['actions'].find { |x| x['id'].to_s == a['id'].to_s }['status'] = 'success'
              end
              { action: a }
            end

            post :poweroff do
              error!({ error: { code: :locked } }, 400) if locked?
              a = Action.add(command: 'stop_server', status: 'running',
                             resources: [{ id: @x['id'], type: 'server' }])
              Thread.new do
                sleep(0.5)
                @x['status'] = 'off'
                $ACTIONS['actions'].find { |x| x['id'].to_s == a['id'].to_s }['status'] = 'success'
              end
              { action: a }
            end

            post :reset_password do
              error!({ error: { code: :locked } }, 400) if locked?
              a = Action.add(command: 'reset_password', status: 'running',
                             resources: [{ id: @x['id'], type: 'server' }])
              Thread.new do
                sleep(0.5)
                $ACTIONS['actions'].find { |x| x['id'].to_s == a['id'].to_s }['status'] = 'success'
              end
              { action: a, root_password: 'test123' }
            end

            post :request_console do
              error!({ error: { code: :locked } }, 400) if locked?
              a = Action.add(command: 'request_console', status: 'running',
                             resources: [{ id: @x['id'], type: 'server' }])
              Thread.new do
                sleep(0.5)
                $ACTIONS['actions'].find { |x| x['id'].to_s == a['id'].to_s }['status'] = 'success'
              end
              {
                action: a,
                wss_url: "wss://web-console.hetzner.cloud/?server_id=#{@x['id']}&token=token",
                password: 'test123'
              }
            end

            params do
              optional :type, type: String
              optional :ssh_keys, type: Array[Integer]
            end
            post :enable_rescue do
              t = params[:type] || 'linux64'
              unless %w[linux64 linux32 freebsd64].include?(t)
                error!({ error: { code: :invalid_input } }, 400)
              end
              error!({ error: { code: :locked } }, 400) if locked?
              a = Action.add(command: 'enable_rescue',  status: 'running',
                             resources: [{ id: @x['id'], type: 'server' }])
              Thread.new do
                sleep(0.5)
                $ACTIONS['actions'].find { |x| x['id'].to_s == a['id'].to_s }['status'] = 'success'
              end
              { action: a, root_password: 'test123' }
            end

            params do
              optional :delete, type: Boolean
              optional :rebuild, type: Boolean
            end
            post :change_protection do
              a = { 'action' => Action.add(command: 'change_protection', status: 'running',
                                           resources: [{ id: @x['id'].to_i, type: 'server' }]) }
              @x['protection']['delete'] = params[:delete] unless params[:delete].nil?
              @x['protection']['rebuild'] = params[:rebuild] unless params[:rebuild].nil?
              a
            end
          end

          params do
            optional :name, type: String
          end
          put do
            if $SERVERS['servers'].any? { |x| x['name'] == params[:name] }
              error!({ error: { code: :uniqueness_error } }, 400)
            end
            @x['name'] = params[:name] unless params[:name].nil?
            @x['labels'] = params[:labels] unless params[:labels].nil?
            { server: @x }
          end

          delete do
            $SERVERS['servers'].delete(@x)
            { action: Action.add(status: 'success', command: 'delete_server',
                                 resources: [{ id: @x['id'], type: 'server' }]) }
          end
        end

        params do
          optional :name, type: String
          optional :server_type, type: String
          optional :datacenter, type: String
          optional :location, type: String
          optional :start_after_create, type: Boolean
          optional :image, type: String
          optional :ssh_keys, type: Array[Integer]
          optional :user_data, type: String
        end
        post do
          server_type = nil
          datacenter = $DATACENTERS['datacenters'].first
          image = $IMAGES['images'].first
          unless params[:name].to_s[/^[A-Za-z0-9-]+$/]
            error!({ error: { code: :invalid_input } }, 400)
          end
          if $SERVERS['servers'].any? { |x| x['name'] == params[:name] }
            error!({ error: { code: :uniqueness_error } }, 400)
          end
          if $SERVER_TYPES['server_types'].none? do |x|
               server_type = x if [x['id'].to_s, x['name']].include?(params[:server_type].to_s)
             end
            error!({ error: { code: :invalid_input, message: 'invalid server_type' } }, 400)
          end
          if $IMAGES['images'].none? do |x|
               image = x if [x['id'].to_s, x['name']].include?(params[:image].to_s)
             end
            error!({ error: { code: :invalid_input, message: 'invalid image' } }, 400)
          end
          if !params[:datacenter].nil? &&
             $DATACENTERS['datacenters'].none? do |x|
               datacenter = x if [x['id'].to_s, x['name']].include?(params[:datacenter].to_s)
             end
            error!({ error: { code: :invalid_input, message: 'invalid datacenter' } }, 400)
          end
          if !params[:location].nil? &&
             $LOCATIONS['locations'].none? do |x|
               [x['id'].to_s, x['name']].include?(params[:location].to_s)
             end
            error!({ error: { code: :invalid_input, message: 'invalid location' } }, 400)
          end
          if params[:ssh_keys].to_a.any? do |id|
               $SSH_KEYS['ssh_keys'].none? { |x| id.to_s == x['id'].to_s }
             end
            error!({ error: { code: :invalid_input, message: 'invalid ssh key' } }, 400)
          end
          id = $SERVER_ID += 1
          s = {
            server: {
              id: id,
              name: params[:name],
              server_type: server_type,
              datacenter: datacenter,
              image: image,
              rescue_enabled: false,
              locked: false,
              backup_window: '22-02',
              outgoing_traffic: 123,
              ingoing_traffic: 123,
              included_traffic: 123,
              iso: nil,
              status: 'initalizing',
              created: Time.now.iso8601,
              protection: {
                delete: false,
                rebuild: false
              },
              public_net: {
                ipv4: {
                  ip: '1.2.3.4',
                  blocked: false,
                  dns_ptr: 'example.com'
                },
                ipv6: {
                  ip: 'fe80::1/64',
                  blocked: false,
                  dns_ptr: []
                },
                floating_ips: [],
                volumes: []
              },
              labels: params[:labels]
            },
            action: Action.add(
              status: 'running',
              command: 'create_server',
              resources: [{ id: id, type: 'server' }]
            ),
            root_password: 'test123'
          }.deep_stringify_keys
          $SERVERS['servers'] << s['server']
          Thread.new do
            sleep(0.5)
            s['server']['status'] = params[:start_after_create] ? 'running' : 'off'
            $ACTIONS['actions'].find { |x| x['id'] == s['action']['id'] }['status'] = 'success'
          end
          s
        end

        params do
          optional :name, type: String
        end
        get do
          dc = $SERVERS.deep_dup

          dc['servers'].select! { |x| x['name'] == params[:name] } unless params[:name].nil?
          unless params[:label_selector].nil?
            dc['servers'].select! do |x|
              FakeService.label_selector_matches(params[:label_selector], x['labels'])
            end
          end

          dc
        end
      end
    end
  end
end
