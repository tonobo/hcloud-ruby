require 'spec_helper'

describe "Datacenter" do
  let :client do
    Hcloud::Client.new(token: "secure")
  end
  it "fetchs datacenters" do
    expect(client.datacenters.count).to eq(2)
  end
  
  it "#[] -> find by id" do
    expect(client.datacenters[1].id).to eq(1)
  end
  
  it "#[] -> find by id, handle nonexistent" do
    expect(client.datacenters[3]).to be nil
  end
  
  it "#find -> find by id" do
    expect(client.datacenters.find(1).id).to eq(1)
  end
  
  it "#find -> find by id, handle nonexistent" do
    expect{client.datacenters.find(3).id}.to raise_error(Hcloud::Error::NotFound)
  end
  
  it "#[] -> filter by name" do
    expect(client.datacenters["fsn1-dc8"].name).to eq("fsn1-dc8")
  end
  
  it "#[] -> filter by name, handle nonexistent" do
    expect(client.datacenters["fsn1-dc3"]).to be nil
  end
  
  it "#[] -> filter by name, handle invalid format" do
    expect{client.datacenters["fsn1dc3"]}.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end
  
  it "#find_by -> filter by name, handle invalid format" do
    expect{client.datacenters.find_by(name: "fsn1dc3")}.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end
end
