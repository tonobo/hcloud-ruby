# frozen_string_literal: true

RSpec.shared_context 'images doubles' do
  def new_image(kwargs = {})
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug,
      description: Faker::Lorem.sentence,
      disk_size: Faker::Number.within(range: 10..100),
      image_size: Faker::Number.within(range: 0.1..10.0),
      # actually, Faker::Computer.os includes both flavor and version; so for our
      # fakes, we're using the platform (Linux, BSD, ...) for the OS flavor
      os_flavor: Faker::Computer.platform,
      os_version: Faker::Computer.os,
      protection: { delete: random_choice(true, false) },
      rapid_deploy: random_choice(true, false),
      status: random_choice('available', 'unavailable', 'creating'),
      type: random_choice('snapshot', 'system', 'app', 'backup', 'temporary'),
      created: Faker::Time.backward,
      deprecated: Faker::Time.backward,
      deleted: random_choice(nil, Faker::Time.backward),
      bound_to: random_choice(nil, Faker::Number.number)
    }.deep_merge(kwargs)
  end
end
