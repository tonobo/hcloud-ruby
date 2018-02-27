require 'spec_helper'

describe 'Generic' do
  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  let :uclient do
    Hcloud::Client.new(token: 'invalid')
  end

  it 'preload all constants' do
    Hcloud.constants.each do |klass|
      Hcloud.send(:const_get, klass)
    end
  end

  it 'check authorized' do
    expect(client.authorized?).to be(true)
  end

  it 'check unauthorized' do
    expect(uclient.authorized?).to be(false)
  end
end
