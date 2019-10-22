# frozen_string_literal: true

module Hcloud
  class Action
    require 'hcloud/action_resource'

    include EntryLoader

    schema(
      started: :time,
      finished: :time
    )
  end
end
