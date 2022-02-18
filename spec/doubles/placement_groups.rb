# frozen_string_literal: true

RSpec.shared_context 'placement_groups doubles' do
  def new_placement_group(kwargs = {})
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug,
      servers: [],
      created: Faker::Time.backward,
      type: 'spread'
    }.deep_merge(kwargs)
  end
end
