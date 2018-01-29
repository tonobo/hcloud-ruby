module Hcloud
  class Iso
    Attributes = {
      id: nil,
      name: nil,
      description: nil,
      type: nil
    }
    
    include EntryLoader
  end
end
