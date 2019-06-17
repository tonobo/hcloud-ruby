# frozen_string_literal: true

module Hcloud
  class Datacenter
    Attributes = {
      id: nil,
      name: nil,
      description: nil,
      location: Location,
      server_types: nil
    }.freeze

    include EntryLoader
  end
end
