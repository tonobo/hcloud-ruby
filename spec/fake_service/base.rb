require 'grape'

module Hcloud
  module FakeService
    class Base < Grape::API
      version "v1", using: :path

      format :json

      before do
        next if headers['Authorization'] == "Bearer secure"
        error!('Unauthorized', 401)
      end

      mount Datacenter
      mount Location
      mount SSHKey
    end
  end
end



