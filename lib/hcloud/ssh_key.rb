# frozen_string_literal: true

module Hcloud
  class SSHKey
    include EntryLoader

    updatable :name
    destructible
  end
end
