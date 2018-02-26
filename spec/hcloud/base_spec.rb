require 'spec_helper'

describe "Generic" do
  it "preload all constants" do
    Hcloud.constants.each do |klass|
      Hcloud.send(:const_get, klass)
    end
  end
end
