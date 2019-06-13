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
      deprecated: :time
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

    def destroy
      request("images/#{id.to_i}", method: :delete).run
      true
    end
  end
end
