# frozen_string_literal: true

require 'hcloud/version'
require 'active_support/core_ext/object/to_query'

module Hcloud
  autoload :Error, 'hcloud/errors'
  autoload :Client, 'hcloud/client'
  autoload :AbstractResource, 'hcloud/abstract_resource'
  autoload :MultiReply, 'hcloud/multi_reply'
  autoload :ServerResource, 'hcloud/server_resource'
  autoload :EntryLoader, 'hcloud/entry_loader'
  autoload :FloatingIP, 'hcloud/floating_ip'
  autoload :FloatingIPResource, 'hcloud/floating_ip_resource'
  autoload :SSHKey, 'hcloud/ssh_key'
  autoload :SSHKeyResource, 'hcloud/ssh_key_resource'
  autoload :Server, 'hcloud/server'
  autoload :ServerType, 'hcloud/server_type'
  autoload :ServerTypeResource, 'hcloud/server_type_resource'
  autoload :Datacenter, 'hcloud/datacenter'
  autoload :DatacenterResource, 'hcloud/datacenter_resource'
  autoload :Location, 'hcloud/location'
  autoload :LocationResource, 'hcloud/location_resource'
  autoload :Image, 'hcloud/image'
  autoload :ImageResource, 'hcloud/image_resource'
  autoload :Network, 'hcloud/network'
  autoload :NetworkResource, 'hcloud/network_resource'
  autoload :Volume, 'hcloud/volume'
  autoload :VolumeResource, 'hcloud/volume_resource'
  autoload :Action, 'hcloud/action'
  autoload :ActionResource, 'hcloud/action_resource'
  autoload :Iso, 'hcloud/iso'
  autoload :IsoResource, 'hcloud/iso_resource'
  autoload :Pagination, 'hcloud/pagination'

  COLLECT_ARGS = proc do |method_name, bind|
    query = bind.receiver.method(method_name).parameters.inject({}) do |hash, (_type, name)|
      hash.merge(name => bind.local_variable_get(name))
    end
    query.delete_if { |_, v| v.nil? }
  end
end
