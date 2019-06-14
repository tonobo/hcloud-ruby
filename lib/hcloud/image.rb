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
      deprecated: :time,
      protection: nil
    }.freeze

    include EntryLoader

    def to_snapshot
      update(type: 'snapshot')
    end

    def update(description: nil, type: nil)
      query = {}
      method(:update).parameters.inject(query) do |r, x|
        (var = eval(x.last.to_s)).nil? ? r : r.merge!(x.last => var)
      end
      Image.new(
        Oj.load(request("images/#{id.to_i}", j: query, method: :put).run.body)['image'],
        parent,
        client
      )
    end

    def change_protection(delete: nil)
      query = {}
      query['delete'] = delete unless delete.nil?
      action(request(base_path('actions/change_protection'), j: query))[0]
    end

    def destroy
      request("images/#{id.to_i}", method: :delete).run
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
      return ["images/#{id}", ext].compact.join('/') unless id.nil?
      raise ResourcePathError, 'Unable to build resource path. Id is nil.'
    end
  end
end
