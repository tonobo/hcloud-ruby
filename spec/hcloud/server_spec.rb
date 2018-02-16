require 'spec_helper'

describe "Server" do
  let :client do
    Hcloud::Client.new(token: "secure")
  end
  it "fetch server" do
    expect(client.servers.count).to eq(0)
  end

  it "create new server, handle missing name" do
    expect{client.servers.create(server_type: "cx11", image: 1)}.to(
      raise_error(ArgumentError)
    )
  end
  
  it "create new server, handle invalid name" do
    expect{client.servers.create(server_type: "cx11", image: 1, name: "moo_moo")}.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end
  
  it "create new server, handle missing server_type" do
    expect{client.servers.create(name: "moo", image: 1)}.to(
      raise_error(ArgumentError)
    )
  end
  
  it "create new server, handle invalid server_type" do
    expect{client.servers.create(server_type: "cx111", image: 1, name: "moo")}.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end
  
  it "create new server, handle missing image" do
    expect{client.servers.create(name: "moo", server_type: "cx11")}.to(
      raise_error(ArgumentError)
    )
  end
  
  it "create new server, handle invalid image" do
    expect{client.servers.create(server_type: "cx11", image: 1234, name: "moo")}.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end
  
  it "create new server, handle invalid datacenter" do
    expect{client.servers.create(name: "moo", server_type: "cx11", image: 1, datacenter: 5)}.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end
  
  it "create new server, handle invalid location" do
    expect{client.servers.create(name: "moo", server_type: "cx11", image: 1, location: 5)}.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end
  
  it "create new server" do
    action, server, pass = nil
    expect do
      action, server, pass = client.servers.create(name: "moo", server_type: "cx11", image: 1)
    end.not_to(raise_error)
    expect(server.id).to be_a Integer
    expect(server.name).to eq("moo")
    expect(server.rescue_enabled).to be false
    expect(server.backup_window).to eq("22-02")
    expect(server.datacenter.id).to eq(1)
    expect(server.locked).to be false
    expect(server.iso).to be nil
    expect(server.created).to be_a Time
    expect(server.outgoing_traffic).to eq(123)
    expect(server.ingoing_traffic).to eq(123)
    expect(server.included_traffic).to eq(123)
    expect(server.image.id).to eq(1)
    expect(server.status).to eq("initalizing")
    expect(server.image.id).to eq(1)
    expect(action.status).to eq("running")
    expect(action.command).to eq("create_server")
    expect(pass).to eq("test123")
  end
  
  it "create new server, custom datacenter" do
    action, server, pass = nil
    expect do
      action, server, pass = client.servers.create(
        name: "foo", server_type: "cx11", image: 1, datacenter: 2,
      )
    end.not_to(raise_error)
    expect(server.id).to be_a Integer
    expect(server.datacenter.id).to eq(2)
    expect(action.status).to eq("running")
  end
  
  it "create new server, start after init" do
    action, server, pass = nil
    expect do
      action, server, pass = client.servers.create(
        name: "bar", server_type: "cx11", image: 1, start_after_create: true,
      )
    end.not_to(raise_error)
    expect(server.id).to be_a Integer
    expect(action.status).to eq("running")
  end
  
  it "create new server, handle name uniqness" do
    expect{client.servers.create(name: "moo", server_type: "cx11", image: 1)}.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
  end
  
  it "check succeded servers and actions" do
    expect(client.servers.all?{|x| x.status == "initalizing"}).to be true
    expect(client.actions.where(status: "running").
           select{|x| x.resources.first["type"] == "server"}.size).to eq(3)
    sleep(0.6)
    expect(client.servers.none?{|x| x.status == "initalizing"}).to be true
    expect(client.servers.group_by{|x| x.status}.map{|k,v| [k,v.size]}.to_h).to(
      eq("off" => 2, "running" => 1)
    )
    expect(client.actions.where(status: "success").
           select{|x| x.resources.first["type"] == "server"}.size).to eq(3)
  end
  
  it "#find()" do
    server = client.servers.find(1)
    expect(server.id).to be_a Integer
    expect(server.name).to eq("moo")
    expect(server.rescue_enabled).to be false
    expect(server.backup_window).to eq("22-02")
    expect(server.datacenter.id).to eq(1)
    expect(server.locked).to be false
    expect(server.iso).to be nil
    expect(server.created).to be_a Time
    expect(server.outgoing_traffic).to eq(123)
    expect(server.ingoing_traffic).to eq(123)
    expect(server.included_traffic).to eq(123)
    expect(server.image.id).to eq(1)
  end
  
  it "#find() -> handle error" do
    expect{client.servers.find(0)}.to raise_error(Hcloud::Error::NotFound)
  end

  it "#find_by(name:)" do
    server = client.servers.find_by(name: "moo")
    expect(server.id).to be_a Integer
    expect(server.name).to eq("moo")
    expect(server.rescue_enabled).to be false
    expect(server.backup_window).to eq("22-02")
    expect(server.datacenter.id).to eq(1)
    expect(server.locked).to be false
    expect(server.iso).to be nil
    expect(server.created).to be_a Time
    expect(server.outgoing_traffic).to eq(123)
    expect(server.ingoing_traffic).to eq(123)
    expect(server.included_traffic).to eq(123)
    expect(server.image.id).to eq(1)
  end
  
  it "#[string]" do
    server = client.servers["moo"]
    expect(server.id).to be_a Integer
    expect(server.name).to eq("moo")
    expect(server.rescue_enabled).to be false
    expect(server.backup_window).to eq("22-02")
    expect(server.datacenter.id).to eq(1)
    expect(server.locked).to be false
    expect(server.iso).to be nil
    expect(server.created).to be_a Time
    expect(server.outgoing_traffic).to eq(123)
    expect(server.ingoing_traffic).to eq(123)
    expect(server.included_traffic).to eq(123)
    expect(server.image.id).to eq(1)
  end

  it "#[string] -> handle nil" do
    expect(client.servers[""]).to be nil
  end
  
  it "#[integer]" do
    server = client.servers[1]
    expect(server.id).to be_a Integer
    expect(server.name).to eq("moo")
    expect(server.rescue_enabled).to be false
    expect(server.backup_window).to eq("22-02")
    expect(server.datacenter.id).to eq(1)
    expect(server.locked).to be false
    expect(server.iso).to be nil
    expect(server.created).to be_a Time
    expect(server.outgoing_traffic).to eq(123)
    expect(server.ingoing_traffic).to eq(123)
    expect(server.included_traffic).to eq(123)
    expect(server.image.id).to eq(1)
  end
  
  it "#[integer] -> handle nil" do
    expect(client.servers[0]).to be nil
  end
  
  it "#update(name:)" do
    expect(client.servers.find(1).name).to eq("moo")
    server = nil
    expect{server = client.servers[1].update(name: "foo")}.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
    expect{server = client.servers[1].update(name: "hui")}.not_to raise_error
    expect(server.name).to eq("hui")
    expect(client.servers.find(1).name).to eq("hui")
  end
  
  it "#destroy" do
    action = nil
    expect{action = client.servers[1].destroy}.not_to raise_error
    expect(action.status).to eq("success")
    expect(client.servers[1]).to be nil
  end

  it "check server actions" do
    id = nil
    expect(client.servers[2].actions.count).to eq(1)
    expect(id = client.servers[2].actions.first.id).to be_a Integer 
    expect(client.servers[2].actions[id].id).to eq(id)
  end
  
  it "#poweroff" do
    expect(client.servers[2].poweroff).to be_a Hcloud::Action
    expect(client.servers[2].actions.count{|x| x.command == "stop_server"}).to eq(1)
  end
  
  it "#poweron" do
    expect{client.servers[2].poweron}.to raise_error(Hcloud::Error::Locked)
    sleep(0.5)
    expect(client.servers[2].status).to eq("off")
    expect(client.servers[2].poweron).to be_a Hcloud::Action
    expect(client.servers[2].actions.count{|x| x.command == "start_server"}).to eq(1)
  end
  
  it "#reset_password" do
    expect{client.servers[2].reset_password}.to raise_error(Hcloud::Error::Locked)
    sleep(0.5)
    action, pass = nil
    expect{action, pass = client.servers[2].reset_password}.not_to raise_error
    expect(action).to be_a Hcloud::Action
    expect(action.command).to eq("reset_password")
    expect(action.status).to eq("running")
    expect(pass).to eq("test123")
  end

  it "#enable_rescue" do
    expect{client.servers[2].enable_rescue(type: "moo")}.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
    expect{client.servers[2].enable_rescue}.to(
      raise_error(Hcloud::Error::Locked)
    )
    sleep(0.5)
    action, pass = nil
    expect{action, pass = client.servers[2].enable_rescue(type: "linux32")}.not_to raise_error
    expect(action).to be_a Hcloud::Action
    expect(action.command).to eq("enable_rescue")
    expect(action.status).to eq("running")
    expect(pass).to eq("test123")
  end
  
end