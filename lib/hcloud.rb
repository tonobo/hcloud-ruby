# frozen_string_literal: true

require 'hcloud/version'
require 'active_support'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'

module Hcloud
  autoload :Error, 'hcloud/errors'
  autoload :Client, 'hcloud/client'
  autoload :Future, 'hcloud/future'
  autoload :TyphoeusExt, 'hcloud/typhoeus_ext'
  autoload :AbstractResource, 'hcloud/abstract_resource'
  autoload :EntryLoader, 'hcloud/entry_loader'
  autoload :ResourceLoader, 'hcloud/resource_loader'

  autoload :Server, 'hcloud/server'
  autoload :ServerResource, 'hcloud/server_resource'

  autoload :ServerType, 'hcloud/server_type'
  autoload :ServerTypeResource, 'hcloud/server_type_resource'

  autoload :FloatingIP, 'hcloud/floating_ip'
  autoload :FloatingIPResource, 'hcloud/floating_ip_resource'

  autoload :PrimaryIP, 'hcloud/primary_ip'
  autoload :PrimaryIPResource, 'hcloud/primary_ip_resource'

  autoload :SSHKey, 'hcloud/ssh_key'
  autoload :SSHKeyResource, 'hcloud/ssh_key_resource'

  autoload :Certificate, 'hcloud/certificate'
  autoload :CertificateResource, 'hcloud/certificate_resource'

  autoload :Datacenter, 'hcloud/datacenter'
  autoload :DatacenterResource, 'hcloud/datacenter_resource'

  autoload :Location, 'hcloud/location'
  autoload :LocationResource, 'hcloud/location_resource'

  autoload :Image, 'hcloud/image'
  autoload :ImageResource, 'hcloud/image_resource'

  autoload :Network, 'hcloud/network'
  autoload :NetworkResource, 'hcloud/network_resource'

  autoload :Firewall, 'hcloud/firewall'
  autoload :FirewallResource, 'hcloud/firewall_resource'

  autoload :Volume, 'hcloud/volume'
  autoload :VolumeResource, 'hcloud/volume_resource'

  autoload :Action, 'hcloud/action'
  autoload :ActionResource, 'hcloud/action_resource'

  autoload :Iso, 'hcloud/iso'
  autoload :IsoResource, 'hcloud/iso_resource'

  autoload :Pagination, 'hcloud/pagination'

  autoload :PlacementGroup, 'hcloud/placement_group'
  autoload :PlacementGroupResource, 'hcloud/placement_group_resource'

  autoload :LoadBalancerType, 'hcloud/load_balancer_type'
  autoload :LoadBalancerTypeResource, 'hcloud/load_balancer_type_resource'

  autoload :LoadBalancer, 'hcloud/load_balancer'
  autoload :LoadBalancerResource, 'hcloud/load_balancer_resource'

  COLLECT_ARGS = proc do |method_name, bind|
    query = bind.receiver.method(method_name).parameters.inject({}) do |hash, (_type, name)|
      hash.merge(name => bind.local_variable_get(name))
    end
    query.delete_if { |_, v| v.nil? }
  end
end
