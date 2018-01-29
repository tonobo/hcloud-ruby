module Hcloud
  class Datacenter
    Attributes = {
      id: nil,
      name: nil,
      description: nil,
      location: Location,
      server_types: nil,
    }

    include EntryLoader

  end
end
