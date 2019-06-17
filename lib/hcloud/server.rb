# frozen_string_literal: true

module Hcloud
  class Server
    Attributes = {
      id: nil,
      name: nil,
      status: nil,
      created: :time,
      public_net: nil,
      server_type: ServerType,
      datacenter: Datacenter,
      image: Image,
      iso: nil,
      rescue_enabled: nil,
      locked: nil,
      backup_window: nil,
      outgoing_traffic: nil,
      ingoing_traffic: nil,
      included_traffic: nil,
      protection: nil
    }.freeze

    include EntryLoader

    def update(name:)
      Server.new(
        Oj.load(request(base_path, j: { name: name }, method: :put).run.body)['server'],
        parent,
        client
      )
    end

    def destroy
      action(request(base_path, method: :delete))[0]
    end

    def enable_rescue(type: 'linux64', ssh_keys: [])
      query = {}
      method(:enable_rescue).parameters.inject(query) do |r, x|
        (var = eval(x.last.to_s)).nil? ? r : r.merge!(x.last => var)
      end
      a, j = action(request(base_path('actions/enable_rescue'), j: query))
      [a, j['root_password']]
    end

    def reset_password
      a, j = action(request(base_path('actions/reset_password'), method: :post))
      [a, j['root_password']]
    end

    def create_image(description: nil, type: nil)
      query = {}
      method(:create_image).parameters.inject(query) do |r, x|
        (var = eval(x.last.to_s)).nil? ? r : r.merge!(x.last => var)
      end
      a, j = action(request(base_path('actions/create_image'), j: query))
      [a, Image.new(j['image'], parent, client)]
    end

    def rebuild(image:)
      a, j = action(request(base_path('actions/rebuild'), j: { image: image }))
      [a, j['root_password']]
    end

    def change_type(server_type:, upgrade_disk: nil)
      query = {}
      method(:change_type).parameters.inject(query) do |r, x|
        (var = eval(x.last.to_s)).nil? ? r : r.merge!(x.last => var)
      end
      action(request(base_path('actions/change_type'), j: query))[0]
    end

    def enable_backup(backup_window:)
      action(request(base_path('actions/enable_backup'),
                     j: { backup_window: backup_window }))[0]
    end

    def attach_iso(iso:)
      action(request(base_path('actions/attach_iso'),
                     j: { iso: iso }))[0]
    end

    %w[
      poweron poweroff shutdown reboot reset
      disable_rescue disable_backup detach_iso
    ].each do |action|
      define_method(action) do
        action(request(base_path("actions/#{action}"), method: :post))[0]
      end
    end

    def change_protection(delete: nil, rebuild: nil)
      query = {}
      query['delete'] = delete unless delete.nil?
      query['rebuild'] = rebuild unless rebuild.nil?
      action(request(base_path('actions/change_protection'), j: query))[0]
    end

    def actions
      ActionResource.new(client: client, parent: self, base_path: base_path)
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
      return ["servers/#{id}", ext].compact.join('/') unless id.nil?

      raise ResourcePathError, 'Unable to build resource path. Id is nil.'
    end
  end
end
