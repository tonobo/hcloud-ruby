require 'spec_helper'

describe "Location" do
  let :client do
    Hcloud::Client.new(token: "secure")
  end
  it "fetchs locations" do
    expect(client.locations.count).to eq(2)
  end
  
  it "#[] -> find by id" do
    expect(client.locations[1].id).to eq(1)
  end
  
  it "#[] -> find by id, handle nonexistent" do
    expect(client.locations[3]).to be nil
  end
  
  it "#find -> find by id" do
    expect(client.locations.find(1).id).to eq(1)
  end
  
  it "#find -> find by id, handle nonexistent" do
    expect{client.locations.find(3).id}.to raise_error(Hcloud::Error::NotFound)
  end
  
  it "#[] -> filter by name" do
    expect(client.locations["fsn1"].name).to eq("fsn1")
  end
  
  it "#[] -> filter by name, handle nonexistent" do
    expect(client.locations["mooo"]).to be nil
  end
end
