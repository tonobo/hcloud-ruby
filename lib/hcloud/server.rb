# frozen_string_literal: true

module Hcloud
  class Server
    require 'hcloud/server_resource'

    include EntryLoader

    schema(
      created: :time,
      server_type: ServerType,
      datacenter: Datacenter,
      image: Image,
      iso: Iso,
      private_net: [Network],
      volumes: [Volume]
    )

    protectable :delete, :rebuild
    updatable :name
    destructible

    has_actions

    def enable_rescue(type: 'linux64', ssh_keys: [])
      query = COLLECT_ARGS.call(__method__, binding)
      prepare_request('actions/enable_rescue', j: query) { |j| j[:root_password] }
    end

    def reset_password
      prepare_request('actions/reset_password', method: :post) { |j| j[:root_password] }
    end

    def create_image(description: nil, type: nil)
      query = COLLECT_ARGS.call(__method__, binding)
      prepare_request('actions/create_image', j: query) { |j| Image.new(client, j[:image]) }
    end

    def rebuild(image:)
      prepare_request('actions/rebuild', j: { image: image }) { |j| j[:root_password] }
    end

    def change_type(server_type:, upgrade_disk: nil)
      prepare_request('actions/change_type', j: COLLECT_ARGS.call(__method__, binding))
    end

    # Specifying a backup window is not supported anymore. We keep this method
    # to ensure backwards compatibility, but ignore the argument if provided.
    def enable_backup(**_kwargs)
      prepare_request('actions/enable_backup', method: :post)
    end

    def attach_iso(iso:)
      prepare_request('actions/attach_iso', j: { iso: iso })
    end

    def attach_to_network(network:, ip: nil, alias_ips: nil)
      prepare_request('actions/attach_to_network', j: COLLECT_ARGS.call(__method__, binding))
    end

    def detach_from_network(network:)
      prepare_request('actions/detach_from_network', j: { network: network })
    end

    %w[
      poweron poweroff shutdown reboot reset
      disable_rescue disable_backup detach_iso
      request_console
    ].each do |action|
      define_method(action) do
        prepare_request("actions/#{action}", method: :post)
      end
    end

    def request_console
      prepare_request('actions/request_console', method: :post) { |j| [j[:wss_url], j[:password]] }
    end
  end
end
