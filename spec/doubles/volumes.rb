# frozen_string_literal: true

RSpec.shared_context 'volumes doubles' do
  def new_volume(kwargs = {})
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug(glue: '-'),
      created: Faker::Time.backward,
      format: random_choice(nil, 'ext4', 'xfs'),
      linux_device: '/dev/disk/by-id/scsi-0HC_Volume_1234',
      location: new_location,
      protection: { delete: random_choice(true, false), rebuild: random_choice(true, false) },
      server: nil,
      size: Faker::Number.within(range: 25..1000),
      status: 'available'
    }.deep_merge(kwargs)
  end
end
