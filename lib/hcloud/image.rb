module Hcloud
  class Image
    Attributes = {
      id: nil,
      type: nil,
      status: nil,
      name: nil,
      description: nil,
      image_size: nil,
      disk_size: nil,
      created: :time,
      created_from: nil,
      bound_to: nil,
      os_flavor: nil,
      os_version: nil,
      rapid_deploy: nil,
    }

    include EntryLoader

  end
end
