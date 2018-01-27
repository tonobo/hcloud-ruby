require "hcloud/version"

module Hcloud
  autoload :Error, 'hcloud/errors'
  autoload :Client, 'hcloud/client'
  autoload :AbstractResource, 'hcloud/abstract_resource'
  autoload :ServerResource, 'hcloud/server_resource'
  autoload :EntryLoader, 'hcloud/entry_loader'
  autoload :Server, 'hcloud/server'
end
