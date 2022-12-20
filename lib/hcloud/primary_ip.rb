# frozen_string_literal: true

module Hcloud
  class PrimaryIP
    require 'hcloud/primary_ip_resource'

    include EntryLoader

    schema(
      datacenter: Datacenter,
      created: :time
    )

    protectable :delete
    updatable :name, :auto_delete
    destructible

    def assign(assignee_id:, assignee_type: 'server')
      raise Hcloud::Error::InvalidInput, 'no assignee_id given' if assignee_id.nil?
      raise Hcloud::Error::InvalidInput, 'no assignee_type given' if assignee_type.nil?

      prepare_request('actions/assign', j: COLLECT_ARGS.call(__method__, binding))
    end

    def unassign
      prepare_request('actions/unassign', method: :post)
    end

    def change_dns_ptr(ip:, dns_ptr:)
      raise Hcloud::Error::InvalidInput, 'no IP given' if ip.blank?

      prepare_request('actions/change_dns_ptr', j: { ip: ip, dns_ptr: dns_ptr })
    end
  end
end
