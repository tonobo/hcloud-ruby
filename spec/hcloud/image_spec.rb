require 'spec_helper'

describe 'Image' do
  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  it 'fetch images' do
    expect(client.images.count).to eq(2)
  end

  it '#[] -> find by id (system image)' do
    expect(client.images.first).to be_a Hcloud::Image
    id = client.images.first.id
    expect(id).to be_a Integer
    expect(client.images[id]).to be_a Hcloud::Image
    expect(client.images[id].name).to be_a String
    expect(client.images[id].type).to be_a String
    expect(client.images[id].status).to be_a String
    expect(client.images[id].name).to be_a String
    expect(client.images[id].description).to be_a String
    expect(client.images[id].created_from).to be nil
    expect(client.images[id].created).to be_a Time
    expect(client.images[id].bound_to).to be nil
    expect(client.images[id].os_flavor).to be_a String
    expect(client.images[id].os_version).to be_a String
    expect(client.images[id].rapid_deploy).to be true
  end

  it '#[] -> find by id (snapshot image)' do
    expect(client.images[3454]).to be_a Hcloud::Image
    expect(client.images[3454].name).to be nil
    expect(client.images[3454].type).to be_a String
    expect(client.images[3454].status).to be_a String
    expect(client.images[3454].name).to be nil
    expect(client.images[3454].description).to be_a String
    expect(client.images[3454].created_from).to be_a Hash
    expect(client.images[3454].created).to be_a Time
    expect(client.images[3454].bound_to).to be nil
    expect(client.images[3454].os_flavor).to be_a String
    expect(client.images[3454].os_version).to be nil
    expect(client.images[3454].rapid_deploy).to be false
  end

  it '#update(description:) - handle nil' do
    expect { client.images[3454].update(description: nil) }.not_to(
      raise_error
    )
  end

  it '#update(description:)' do
    expect(client.images[3454].description).not_to eq('test123')
    expect(client.images[3454].update(description: 'test123').description).to eq('test123')
    expect(client.images[3454].description).to eq('test123')
  end

  it '#update(type:) - handle invalid' do
    expect { client.images.first.update(type: 'moo') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it '#update(type:) - handle nil' do
    expect { client.images.first.update(type: nil) }.not_to(
      raise_error
    )
  end

  it '#update(type:) - handle backup convert for predefinded images' do
    expect { client.images.first.update(type: 'backup') }.to(
      raise_error(Hcloud::Error::NotFound)
    )
  end

  it '#to_snapshot' do
    expect(client.images[3454].description).to eq('test123')
    expect(client.images[3454].to_snapshot).to be_a Hcloud::Image
  end

  it '#where(name:)' do
    expect(client.images.where(name: 'moo').count).to eq(0)
    expect(client.images.where(name: 'ubuntu-16.04').count).to eq(1)
    x = client.images.where(name: 'ubuntu-16.04').first
    expect(x).to be_a Hcloud::Image
    expect(x.name).to be_a String
    expect(x.type).to be_a String
    expect(x.status).to be_a String
    expect(x.name).to be_a String
    expect(x.description).to be_a String
    expect(x.created_from).to be nil
    expect(x.created).to be_a Time
    expect(x.bound_to).to be nil
    expect(x.os_flavor).to be_a String
    expect(x.os_version).to be_a String
    expect(x.rapid_deploy).to be true
  end

  it '#[] -> find by id, handle nonexistent' do
    expect(client.images[0]).to be nil
  end

  it '#find -> find by id' do
    expect(client.images.first).to be_a Hcloud::Image
    id = client.images.first.id
    expect(id).to be_a Integer
    expect(client.images.find(id)).to be_a Hcloud::Image
    expect(client.images.find(id).name).to be_a String
    expect(client.images.find(id).type).to be_a String
    expect(client.images.find(id).status).to be_a String
    expect(client.images.find(id).name).to be_a String
    expect(client.images.find(id).description).to be_a String
    expect(client.images.find(id).created_from).to be nil
    expect(client.images.find(id).created).to be_a Time
    expect(client.images.find(id).bound_to).to be nil
    expect(client.images.find(id).os_flavor).to be_a String
    expect(client.images.find(id).os_version).to be_a String
    expect(client.images.find(id).rapid_deploy).to be true
  end

  it '#find -> find by id, handle nonexistent' do
    expect { client.images.find(0).id }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#[] -> filter by name' do
    expect(client.images['ubuntu-16.04']).to be_a Hcloud::Image
    expect(client.images['ubuntu-16.04'].name).to be_a String
    expect(client.images['ubuntu-16.04'].type).to be_a String
    expect(client.images['ubuntu-16.04'].status).to be_a String
    expect(client.images['ubuntu-16.04'].name).to be_a String
    expect(client.images['ubuntu-16.04'].description).to be_a String
    expect(client.images['ubuntu-16.04'].created_from).to be nil
    expect(client.images['ubuntu-16.04'].created).to be_a Time
    expect(client.images['ubuntu-16.04'].bound_to).to be nil
    expect(client.images['ubuntu-16.04'].os_flavor).to be_a String
    expect(client.images['ubuntu-16.04'].os_version).to be_a String
    expect(client.images['ubuntu-16.04'].rapid_deploy).to be true
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.images['mooo']).to be nil
  end

  it '#destroy()' do
    expect(client.images.count).to eq(2)
    expect { client.images[3454].destroy }.not_to raise_error
    expect(client.images.count).to eq(1)
  end
end
