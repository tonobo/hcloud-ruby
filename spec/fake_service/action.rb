# frozen_string_literal: true

require 'time'

module Hcloud
  module FakeService
    $ACTION_ID = 0
    $ACTIONS = {
      'actions' => [],
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

    class Action < Grape::API
      class << self
        def add(h = {})
          a = {
            id: $ACTION_ID += 1,
            progress: 0,
            started: Time.now.iso8601,
            finished: nil,
            error: nil
          }.merge(h).deep_stringify_keys
          $ACTIONS['actions'] << a
          a
        end
      end
      group :actions do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before_validation do
            @x = $ACTIONS['actions'].find { |x| x['id'].to_s == params[:id].to_s }
            error!({ error: { code: :not_found } }, 404) if @x.nil?
          end
          get do
            { action: @x }
          end
        end

        params do
          optional :status, type: String
          optional :per_page, type: Integer
          optional :page, type: Integer
          optional :sort, type: String
        end
        get do
          dc = $ACTIONS.deep_dup
          unless params[:status].nil?
            dc['actions'].select! { |x| x['status'].to_s == params[:status].to_s }
          end
          dc['actions'].shuffle!
          unless params[:sort].nil?
            dc['actions'].sort_by! { |x| x[params[:sort].split(':')[0]] }
            dc['actions'].reverse! if params[:sort].end_with?(':desc')
          end
          FakeService.pagination_wrapper(dc, 'actions', params[:per_page], params[:page])
        end
      end
    end
  end
end
