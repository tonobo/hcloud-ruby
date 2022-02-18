# frozen_string_literal: true

module Hcloud
  class PlacementGroup
    require 'hcloud/placement_group_resource'

    include EntryLoader

    schema(
      created: :time
    )

    updatable :name
    destructible
  end
end
