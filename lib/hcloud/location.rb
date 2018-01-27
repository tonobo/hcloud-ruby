module Hcloud
  class Location
    Attributes = {
      id: nil,
      name: nil,
      description: nil,
      country: nil,
      city: nil,
      longitude: nil,
      latitude: nil,
    }

    include EntryLoader

  end
end
