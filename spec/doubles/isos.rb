# frozen_string_literal: true

RSpec.shared_context 'isos doubles' do
  def new_iso(kwargs = {})
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug,
      description: Faker::Lorem.sentence,
      type: random_choice(:public, :private),
      deprecated: Faker::Time.backward
    }.deep_merge(kwargs)
  end
end
