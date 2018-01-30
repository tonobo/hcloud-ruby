require "hcloud/version"
require 'active_support/core_ext/object/to_query'

module Hcloud
  autoload :Error, 'hcloud/errors'
  autoload :Client, 'hcloud/client'
  autoload :AbstractResource, 'hcloud/abstract_resource'
  autoload :ServerResource, 'hcloud/server_resource'
  autoload :EntryLoader, 'hcloud/entry_loader'
  autoload :Server, 'hcloud/server'
  autoload :ServerType, 'hcloud/server_type'
  autoload :ServerTypeResource, 'hcloud/server_type_resource'
  autoload :Datacenter, 'hcloud/datacenter'
  autoload :DatacenterResource, 'hcloud/datacenter_resource'
  autoload :Location, 'hcloud/location'
  autoload :LocationResource, 'hcloud/location_resource'
  autoload :Image, 'hcloud/image'
  autoload :ImageResource, 'hcloud/image_resource'
  autoload :Action, 'hcloud/action'
  autoload :ActionResource, 'hcloud/action_resource'
  autoload :Iso, 'hcloud/iso'
  autoload :IsoResource, 'hcloud/iso_resource'
end
