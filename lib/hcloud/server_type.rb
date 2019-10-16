# frozen_string_literal: true

module Hcloud
  class ServerType
    require 'hcloud/server_type_resource'

    include EntryLoader
  end
end
