# frozen_string_literal: true

module Hcloud
  class Datacenter
    require 'hcloud/datacenter_resource'

    include EntryLoader

    schema(
      location: Location
    )
  end
end
