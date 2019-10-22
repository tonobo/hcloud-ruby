# frozen_string_literal: true

module Hcloud
  class ActionResource < AbstractResource
    filter_attributes :status

    bind_to Action
  end
end
