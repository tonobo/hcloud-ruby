module Hcloud
  class Iso
    Attributes = {
      id: nil,
      name: nil,
      description: nil,
      type: nil
    }.freeze

    include EntryLoader
  end
end
