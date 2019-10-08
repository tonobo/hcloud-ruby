# frozen_string_literal: true

module Hcloud
  class Datacenter
    include EntryLoader

    schema(
      location: Location
    )
  end
end
