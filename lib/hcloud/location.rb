module Hcloud
  class Location
    Attributes = {
      id: nil,
      name: nil,
      description: nil,
      country: nil,
      city: nil,
      longitude: nil,
      latitude: nil
    }.freeze

    include EntryLoader
  end
end
