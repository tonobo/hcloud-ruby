# frozen_string_literal: true

module Hcloud
  class Volume
    Attributes = {
      id: nil,
      created: :time,
      name: nil,
      server: nil,
      location: Location,
      size: nil,
      linux_device: nil,
      protection: nil,
      status: nil,
      format: nil
    }.freeze
    include EntryLoader

    def update(name:)
      j = Oj.load(request("volumes/#{id.to_i}",
                          j: { name: name },
                          method: :put).run.body)
      Volume.new(j['volume'], self, client)
    end

    def attach(server:, automount:)
      action(request(base_path('actions/attach'),
                     j: { server: server, automount: automount }))[0]
    end

    def detach
      action(request(base_path('actions/detach'), method: :post))[0]
    end

    def resize(size:)
      action(request(base_path('actions/resize'), j: { size: size }))[0]
    end

    def change_protection(delete: nil)
      query = COLLECT_ARGS.call(__method__, binding)
      action(request(base_path('actions/change_protection'), j: query))[0]
    end

    def actions
      ActionResource.new(client: client, parent: self, base_path: base_path)
    end

    def destroy
      request("volumes/#{id}", method: :delete).run.body
      true
    end

    private

    def action(request)
      j = Oj.load(request.run.body)
      [
        Action.new(j['action'], parent, client),
        j
      ]
    end

    def base_path(ext = nil)
      return ["volumes/#{id}", ext].compact.join('/') unless id.nil?

      raise ResourcePathError, 'Unable to build resource path. Id is nil.'
    end
  end
end
