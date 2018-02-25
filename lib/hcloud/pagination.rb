module Hcloud
  class Pagination
    Attributes = {
      page: nil,
      per_page: nil,
      previous_page: nil,
      next_page: nil,
      last_page: nil,
      total_entries: nil,
    }
    
    include EntryLoader
  end
end
