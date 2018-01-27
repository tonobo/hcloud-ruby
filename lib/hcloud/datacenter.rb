module Hcloud
  class Datacenter
    Attributes = {
      id: nil,
      name: nil,
      description: nil,
      location: Location,
    }

    include EntryLoader

  end
end
