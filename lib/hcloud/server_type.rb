module Hcloud
  class ServerType
    Attributes = {
      id: nil,
      name: nil,
      description: nil,
      cores: nil,
      memory: nil,
      disk: nil,
      prices: nil,
      storage_type: nil
    }.freeze

    include EntryLoader
  end
end
