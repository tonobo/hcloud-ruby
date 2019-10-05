# frozen_string_literal: true

module Hcloud
  class Pagination
    Attributes = {
      page: nil,
      per_page: nil,
      previous_page: nil,
      next_page: nil,
      last_page: nil,
      total_entries: nil
    }.freeze

    include EntryLoader
  end
end
