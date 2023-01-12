# frozen_string_literal: true

require 'spec_helper'

describe 'Image', :integration, integration_helper: :server do
  let(:image_name) { resource_name('image') }

  before(:context) do
    # TODO: Okay, this is extremely hacky, but an integer variable will not do.
    #       If we set an integer on @image_id from some example, another example will see nil.
    #       And there is no way to find an image by description (without listing ALL images).
    @images = []
  end

  before(:each) do
    @image_id = @images[0]
  end

  it 'fetch images' do
    expect(client.images.count).to be_a Integer
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

  it 'create image for tests' do
    server = client.servers[helper_name]
    action, image = server.create_image(
      type: 'snapshot',
      description: image_name
    )
    wait_for_action(server, action.id)

    @images << image.id
  end

  it '#[] -> find by id (snapshot image)' do
    expect(client.images[@image_id]).to be_a Hcloud::Image
    expect(client.images[@image_id].name).to be nil
    expect(client.images[@image_id].type).to eq('snapshot')
    expect(client.images[@image_id].description).to eq(image_name)
    expect(client.images[@image_id].created_from).to be_a Hash
    expect(client.images[@image_id].created).to be_a Time
    expect(client.images[@image_id].rapid_deploy).to be false
  end

  it '#update(description:) - handle nil' do
    # TODO: Is this really expected to work? because it does not, it raises InvalidInput
    expect { client.images[@image_id].update(description: nil) }.not_to(
      raise_error
    )
  end

  it '#update(description:)' do
    new_name = resource_name('image-new')
    expect(client.images[@image_id].description).not_to eq(new_name)
    expect(client.images[@image_id].update(description: new_name).description).to eq(new_name)
    expect(client.images[@image_id].description).to eq(new_name)
  end

  it '#update(type:) - handle invalid' do
    expect { client.images[@image_id].update(type: 'moo') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it '#update(type:) - handle nil' do
    # TODO: Is this really expected to work? because it does not, it raises InvalidInput
    expect { client.images[@image_id].update(type: nil) }.not_to(
      raise_error
    )
  end

  it '#update(type:) - handle backup convert for predefinded images' do
    expect { client.images[@image_id].update(type: 'backup') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it '#update(labels:)' do
    image = client.images[@image_id]
    updated = image.update(labels: { 'source' => 'update' })
    expect(updated.labels).to eq({ 'source' => 'update' })
    expect(client.images[@image_id].labels).to eq({ 'source' => 'update' })
  end

  it '#where -> find by label_selector' do
    images = client.images.where(label_selector: 'source=update').to_a
    expect(images.length).to eq(1)
    expect(images.first.labels).to include('source' => 'update')
  end

  it '#to_snapshot' do
    # need a backup image, cannot convert snapshot to snapshot
    server = client.servers[helper_name]
    action = server.enable_backup
    wait_for_action(server, action.id)

    action, image = server.create_image(
      type: 'backup',
      description: resource_name('image-backup')
    )
    wait_for_action(server, action.id)
    @images << image.id

    client.images[image.id].to_snapshot
    expect(client.images[image.id].type).to eq('snapshot')
  end

  it '#where(name:)' do
    images = client.images.where(name: client.images.first.name)
    expect(images.count).to eq(1)

    x = images.first
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

  it '#where(name:) -> invalid name' do
    expect(client.images.where(name: 'moo').count).to eq(0)
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
    name = client.images.first.name
    expect(client.images[name]).to be_a Hcloud::Image
    expect(client.images[name].name).to be_a String
    expect(client.images[name].type).to be_a String
    expect(client.images[name].status).to be_a String
    expect(client.images[name].name).to be_a String
    expect(client.images[name].description).to be_a String
    expect(client.images[name].created_from).to be nil
    expect(client.images[name].created).to be_a Time
    expect(client.images[name].bound_to).to be nil
    expect(client.images[name].os_flavor).to be_a String
    expect(client.images[name].os_version).to be_a String
    expect(client.images[name].rapid_deploy).to be true
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.images['mooo']).to be nil
  end

  it '#change_protection' do
    expect(client.images[@image_id]).to be_a Hcloud::Image
    expect(client.images[@image_id].protection).to be_a Hash
    expect(client.images[@image_id].protection['delete']).to be false

    expect(client.images[@image_id].change_protection).to be_a Hcloud::Action

    expect(client.images[@image_id].protection).to be_a Hash
    expect(client.images[@image_id].protection['delete']).to be false

    expect(client.images[@image_id].change_protection(delete: true)).to be_a Hcloud::Action

    expect(client.images[@image_id].protection).to be_a Hash
    expect(client.images[@image_id].protection['delete']).to be true

    # disable protection again to allow delete
    client.images[@image_id].change_protection(delete: false)
  end

  it '#destroy()' do
    @images.each do |image_id|
      expect { client.images[image_id].destroy }.not_to raise_error
      expect(client.images[image_id].deleted).not_to be(nil)
    end
  end
end
