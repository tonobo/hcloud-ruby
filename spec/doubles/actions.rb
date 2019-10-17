# frozen_string_literal: true

RSpec.shared_context 'actions doubles' do
  def action_status(status)
    case status
    when :running
      {
        status: :running,
        progress: Faker::Number.within(range: 0...100)
      }
    when :success
      {
        status: 'success',
        progress: 100
      }
    when :error
      {
        status: 'error',
        progress: Faker::Number.within(range: 0..100),
        error: {
          code: 'action_failed',
          message: 'action is failed'
        }
      }
    else
      raise "invalid action status: #{status.inspect}"
    end
  end

  def action(kind = nil, **kwargs)
    {
      id: Faker::Number.number,
      command: 'start_server',
      started: Faker::Time.backward,
      finished: random_choice(Faker::Time.backward, Faker::Time.forward),
      resources: []
    }
      .merge(action_status(kind || random_choice(:error, :running, :success)))
      .deep_merge(kwargs)
  end
end
