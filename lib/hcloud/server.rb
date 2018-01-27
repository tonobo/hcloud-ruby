module Hcloud
  class Server
    Attributes = {
      id: nil,
      name: nil,
      status: nil,
      created: :time,
      public_net: nil,
      server_type: ServerType,
      datacenter: nil,
      image: nil,
      iso: nil,
      rescue_enabled: nil,
      locked: nil,
      backup_window: nil,
      outgoing_traffic: nil,
      ingoing_traffic: nil,
      included_traffic: nil
    }

    include EntryLoader

  end
end
