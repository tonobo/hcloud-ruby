# frozen_string_literal: true

RSpec.shared_context 'servers doubles' do
  def image
    {
      id: Faker::Number.number,
      "type": random_choice(:system, :snapshot, :backup),
      "status": random_choice(:available, :creating),
      "name": 'ubuntu-16.04',
      "description": 'Ubuntu 16.04 Standard 64 bit',
      "image_size": Faker::Number.decimal(l_digits: 1, r_digits: 3),
      "disk_size": Faker::Number.within(range: 25..1000),
      "created": Faker::Time.backward,
      "created_from": {
        "id": 1,
        "name": 'Server'
      },
      "bound_to": nil,
      "os_flavor": 'ubuntu',
      "os_version": '16.04',
      "rapid_deploy": random_choice(true, false),
      "protection": {
        "delete": random_choice(true, false)
      },
      "deprecated": random_choice(nil, Faker::Time.backward),
      "labels": {}
    }
  end

  def iso
    {
      id: Faker::Number.number,
      name: 'FreeBSD-11.0-RELEASE-amd64-dvd1',
      description: 'FreeBSD 11.0 x64',
      type: random_choice(:private, :public),
      deprecated: random_choice(nil, Faker::Time.backward)
    }
  end

  def datacenter(**kwargs)
    {
      id: Faker::Number.number,
      name: "#{random_choice('fsn1', 'ngb1', 'hel1')}-dc#{Faker::Number.within(range: 1..50)}",
      "description": 'Falkenstein 1 DC 8',
      "location": {
        "id": 1,
        "name": 'fsn1',
        "description": 'Falkenstein DC Park 1',
        "country": 'DE',
        "city": 'Falkenstein',
        "latitude": 50.47612,
        "longitude": 12.370071,
        "network_zone": 'eu-central'
      },
      "server_types": {
        "supported": [
          1,
          2,
          3
        ],
        "available": [
          1,
          2,
          3
        ],
        "available_for_migration": [
          1,
          2,
          3
        ]
      }
    }.deep_merge(kwargs)
  end

  def server_type
    {
      id: Faker::Number.number,
      name: "#{random_choice('cx', 'ccx')}#{Faker::Number.within(range: 1..90)}",
      cores: Faker::Number.within(range: 1..30),
      memory: Faker::Number.within(range: 1..200),
      disk: Faker::Number.within(range: 25..1000),
      deprecated: random_choice(true, false),
      prices: [
        {
          location: random_choice('fsn1', 'hel1', 'nbg1'),
          price_hourly: {
            net: Faker::Number.decimal(l_digits: 2)
          },
          price_monthly: {
            net: Faker::Number.decimal(l_digits: 2)
          }
        }
      ],
      storage_type: random_choice(:local, :network),
      cpu_type: random_choice(:shared, :dedicated)
    }.tap do |hash|
      hash[:description] = hash[:name].to_s.upcase
      %i[price_hourly price_monthly].each do |kind|
        price = hash[:prices][0][kind]
        price[:gross] = price[:net] * 1.19
      end
    end
  end

  def new_server(**kwargs)
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug(glue: '-'),
      status: random_choice(
        :running, :initializing, :starting, :stopping, :off, :deleting, :migrating, :rebuilding, :unknown
      ),
      created: Faker::Time.backward,
      public_net: {
        ipv4: {
          ip: Faker::Internet.ip_v4_address,
          blocked: random_choice(true, false),
          dns_ptr: Faker::Internet.domain_name
        },
        ipv6: {
          ip: Faker::Internet.ip_v6_cidr,
          blocked: random_choice(true, false),
          dns_ptr: random_choice(
            [],
            [{ ip: Faker::Internet.ip_v6_address, dns_ptr: Faker::Internet.domain_name }]
          )
        },
        floating_ips: []
      },
      private_net: [{
        alias_ips: [],
        ip: '10.0.0.2',
        mac_address: '86:00:ff:2a:7d:e1',
        network: 4711
      }],
      server_type: server_type,
      datacenter: datacenter,
      image: random_choice(nil, image),
      iso: random_choice(nil, iso),
      rescue_enabled: random_choice(true, false),
      locked: random_choice(true, false),
      backup_window: '22-02',
      outgoing_traffic: Faker::Number.number,
      ingoing_traffic: Faker::Number.number,
      included_traffic: Faker::Number.number,
      protection: { delete: random_choice(true, false), rebuild: random_choice(true, false) },
      labels: {},
      volumes: []
    }.deep_merge(kwargs)
  end

  def new_volume(**kwargs)
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug(glue: '-'),
      created: Faker::Time.backward,
      format: 'xfs',
      linux_device: '/dev/disk/by-id/scsi-0HC_Volume_1234',
      location: {
        city: 'Falkenstein',
        country: 'DE',
        description: 'Falkenstein DC Park 1',
        id: 1,
        latitude: 50.47612,
        longitude: 12.370071,
        name: 'fsn1',
        network_zone: 'eu-central'
      },
      protection: { delete: random_choice(true, false), rebuild: random_choice(true, false) },
      server: nil,
      size: Faker::Number.within(range: 25..1000),
      status: 'available'
    }.deep_merge(kwargs)
  end
end
