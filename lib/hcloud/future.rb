module Hcloud
  class Future < Delegator
    class << self
      alias [] new
    end
    def initialize(target_class)
      @target_class = target_class
    end
    def __getobj__
      @obj
    end
    def __setobj__(obj)
      raise "Unexpected target class" if obj.is_a?(@target_class)
      @obj = obj
    end
  end
end
