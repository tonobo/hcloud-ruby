# frozen_string_literal: true

module Hcloud
  module FakeService
    $SSH_KEY_ID = 0
    $SSH_KEYS = {
      'ssh_keys' => [],
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

    class SSHKey < Grape::API
      group :ssh_keys do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before_validation do
            @x = $SSH_KEYS['ssh_keys'].find { |x| x['id'].to_s == params[:id].to_s }
            error!({ error: { code: :not_found } }, 404) if @x.nil?
          end
          get do
            { ssh_key: @x }
          end

          params do
            optional :name, type: String
          end
          put do
            @x['name'] = params[:name] unless params[:name].nil?
            @x['labels'] = params[:labels] unless params[:labels].nil?
            { ssh_key: @x }
          end

          delete do
            $SSH_KEYS['ssh_keys'].delete(@x)
            @body = nil
            status 204
          end
        end

        params do
          optional :name, type: String
          optional :public_key, type: String
        end
        post do
          error!({ error: { code: :invalid_input } }, 400) if params[:name].nil?
          unless params[:public_key].to_s.start_with?('ssh-')
            error!({ error: { code: :invalid_input } }, 400)
          end
          if $SSH_KEYS['ssh_keys'].any? { |x| params[:public_key] == x['public_key'] }
            error!({ error: { code: :uniqueness_error } }, 400)
          end
          if $SSH_KEYS['ssh_keys'].any? { |x| params[:name] == x['name'] }
            error!({ error: { code: :uniqueness_error } }, 400)
          end
          key = {
            'id' => $SSH_KEY_ID += 1,
            'name' => params[:name],
            'fingerprint' => 0.upto(15).map { rand(0..255) }.map { |num| num.to_s(16) }.join(':'),
            'public_key' => params[:public_key],
            'labels' => params[:labels]
          }
          $SSH_KEYS['ssh_keys'] << key
          { ssh_key: key }
        end

        params do
          optional :name, type: String
        end
        get do
          ssh_keys = $SSH_KEYS.deep_dup

          ssh_keys['ssh_keys'].select! { |x| x['name'] == params[:name] } unless params[:name].nil?
          unless params[:label_selector].nil?
            ssh_keys['ssh_keys'].select! do |x|
              FakeService.label_selector_matches(params[:label_selector], x['labels'])
            end
          end

          ssh_keys
        end
      end
    end
  end
end
