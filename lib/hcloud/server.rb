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
      load_balancers: [LoadBalancer],
      placement_group: PlacementGroup,
      private_net: [Network],
      public_net: {
        ipv4: lambda do |data, client|
          Future.new(client, PrimaryIP, data[:id]) if data.to_h[:id].is_a?(Integer)
        end,
        ipv6: lambda do |data, client|
          Future.new(client, PrimaryIP, data[:id]) if data.to_h[:id].is_a?(Integer)
        end,
        floating_ips: [FloatingIP],
        firewalls: [{ id: Firewall }]
      },
      volumes: [Volume]
    )

    protectable :delete, :rebuild
    updatable :name
    destructible

    has_actions
    has_metrics

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
      raise Hcloud::Error::InvalidInput, 'no image given' if image.blank?

      prepare_request('actions/rebuild', j: { image: image }) { |j| j[:root_password] }
    end

    def change_type(server_type:, upgrade_disk:)
      raise Hcloud::Error::InvalidInput, 'no server_type given' if server_type.blank?
      raise Hcloud::Error::InvalidInput, 'no upgrade_disk given' if upgrade_disk.nil?

      prepare_request('actions/change_type', j: COLLECT_ARGS.call(__method__, binding))
    end

    # Specifying a backup window is not supported anymore. We keep this method
    # to ensure backwards compatibility, but ignore the argument if provided.
    def enable_backup(**_kwargs)
      prepare_request('actions/enable_backup', method: :post)
    end

    def attach_iso(iso:)
      raise Hcloud::Error::InvalidInput, 'no iso given' if iso.blank?

      prepare_request('actions/attach_iso', j: { iso: iso })
    end

    def attach_to_network(network:, ip: nil, alias_ips: nil)
      raise Hcloud::Error::InvalidInput, 'no network given' if network.nil?

      prepare_request('actions/attach_to_network', j: COLLECT_ARGS.call(__method__, binding))
    end

    def detach_from_network(network:)
      raise Hcloud::Error::InvalidInput, 'no network given' if network.nil?

      prepare_request('actions/detach_from_network', j: { network: network })
    end

    def add_to_placement_group(placement_group:)
      raise Hcloud::Error::InvalidInput, 'no placement_group given' if placement_group.nil?

      prepare_request('actions/add_to_placement_group', j: COLLECT_ARGS.call(__method__, binding))
    end

    def change_alias_ips(alias_ips:, network:)
      raise Hcloud::Error::InvalidInput, 'no alias_ips given' if alias_ips.to_a.count.zero?
      raise Hcloud::Error::InvalidInput, 'no network given' if network.nil?

      prepare_request('actions/change_alias_ips', j: COLLECT_ARGS.call(__method__, binding))
    end

    def change_dns_ptr(ip:, dns_ptr:)
      raise Hcloud::Error::InvalidInput, 'no IP given' if ip.blank?
      raise Hcloud::Error::InvalidInput, 'no dns_ptr given' if dns_ptr.blank?

      prepare_request('actions/change_dns_ptr', j: COLLECT_ARGS.call(__method__, binding))
    end

    %w[
      poweron poweroff shutdown reboot reset
      disable_rescue disable_backup detach_iso
      request_console remove_from_placement_group
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
