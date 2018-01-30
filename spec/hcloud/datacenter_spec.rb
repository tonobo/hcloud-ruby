require 'spec_helper'

describe "Datacenter" do
  let :client do
    Hcloud::Client.new(token: "secure")
  end
  it "fetch datacenters" do
    expect(client.datacenters.count).to eq(2)
  end
end
