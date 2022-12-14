# frozen_string_literal: true

module Hcloud
  class SSHKey
    require 'hcloud/ssh_key_resource'

    include EntryLoader

    schema(
      created: :time
    )

    updatable :name
    destructible
  end
end
