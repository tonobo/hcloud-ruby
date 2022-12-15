# frozen_string_literal: true

module Hcloud
  module FakeService
    $FIREWALL_ID = 0
    $FIREWALLS = {
      'firewalls' => [],
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

    class Firewall < Grape::API
      group :firewalls do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before_validation do
            @x = $FIREWALLS['firewalls'].find { |x| x['id'].to_s == params[:id].to_s }
            error!({ error: { code: :not_found } }, 404) if @x.nil?
          end
          get do
            { firewall: @x }
          end

          group :actions do
            params do
              requires :aid, type: Integer
            end
            route_param :aid do
              before_validation do
                @a = Action.resource_action('firewall', @x['id'], params[:aid])
                error!({ error: { code: :not_found } }, 404) if @a.nil?
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
              actions = Action.resource_actions('firewall', @x['id'])
              unless params[:status].nil?
                actions['actions'].select! do |x|
                  x['status'].to_s == params[:status].to_s
                end
              end
              actions
            end

            params do
              optional :rules, type: Array
            end
            post :set_rules do
              error!({ error: { code: :invalid_input } }, 400) if params[:rules].nil?

              @x['rules'] = params[:rules]

              a = Action.add(command: 'set_rules', status: 'success',
                             resources: [{ id: @x['id'], type: 'firewall' }])
              { actions: [a] }
            end

            params do
              optional :apply_to, type: Array
            end
            post :apply_to_resources do
              error!({ error: { code: :invalid_input } }, 400) if params[:apply_to].nil?

              @x['applied_to'].concat(params[:apply_to].map(&:to_h))

              a = Action.add(command: 'apply_to_resources', status: 'success',
                             resources: [{ id: @x['id'], type: 'firewall' }])
              { actions: [a] }
            end

            params do
              optional :remove_from, type: Array
            end
            post :remove_from_resources do
              error!({ error: { code: :invalid_input } }, 400) if params[:remove_from].nil?

              params[:remove_from].each do |remove_from|
                @x['applied_to'].delete_if do |applied_to|
                  next unless remove_from['type'] == applied_to['type']

                  case applied_to['type']
                  when 'server'
                    remove_from.dig('server', 'id') == applied_to.dig('server', 'id')
                  when 'label_selector'
                    remove_from.dig('label_selector', 'selector') \
                      == applied_to.dig('label_selector', 'selector')
                  end
                end
              end

              a = Action.add(command: 'remove_from_resources', status: 'success',
                             resources: [{ id: @x['id'], type: 'firewall' }])
              { actions: [a] }
            end
          end

          params do
            optional :name, type: String
          end
          put do
            @x['name'] = params[:name] unless params[:name].nil?
            @x['labels'] = params[:labels] unless params[:labels].nil?
            { firewall: @x }
          end

          delete do
            $FIREWALLS['firewalls'].delete(@x)
            @body = nil
            status 204
          end
        end

        params do
          optional :name, type: String
          optional :rules, type: Array
          optional :apply_to, type: Array
        end
        post do
          error!({ error: { code: :invalid_input } }, 400) if params[:name].nil?

          if $FIREWALLS['firewalls'].any? { |x| params[:name] == x['name'] }
            error!({ error: { code: :uniqueness_error } }, 400)
          end

          firewall = {
            'id' => $FIREWALL_ID += 1,
            'name' => params[:name],
            'applied_to' => params[:apply_to] || [],
            'rules' => params[:rules] || [],
            'labels' => params[:labels] || {}
          }

          actions = []
          unless params[:rules].to_a.empty?
            actions << Action.add(command: 'set_rules', status: 'running',
                                  resources: [{ id: firewall['id'], type: 'firewall' }])
          end
          unless params[:apply_to].to_a.empty?
            actions << Action.add(command: 'apply_to_resources', status: 'running',
                                  resources: [{ id: firewall['id'], type: 'firewall' }])
          end

          $FIREWALLS['firewalls'] << firewall
          { actions: actions, firewall: firewall }
        end

        params do
          optional :name, type: String
        end
        get do
          firewalls = $FIREWALLS.deep_dup

          unless params[:name].nil?
            firewalls['firewalls'].select! { |x| x['name'] == params[:name] }
          end

          unless params[:label_selector].nil?
            firewalls['firewalls'].select! do |x|
              FakeService.label_selector_matches(params[:label_selector], x['labels'])
            end
          end

          firewalls
        end
      end
    end
  end
end
