# frozen_string_literal: true

module Hcloud
  class Iso
    Attributes = {
      id: nil,
      name: nil,
      description: nil,
      type: nil,
      deprecated: :time
    }.freeze

    include EntryLoader
  end
end
