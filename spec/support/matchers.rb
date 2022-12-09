# frozen_string_literal: true

RSpec::Matchers.define :have_body_params do |params|
  match do |request|
    body = body_params(request)

    values_match?(params, body)
  end
  failure_message do |request|
    "expected request to #{request.base_url} to have body params #{params}, " \
      + "but had #{body_params(request)}"
  end
  failure_message_when_negated do |request|
    "expected request to #{request.base_url} to not have body params #{params}, " \
      + "but had #{body_params(request)}"
  end

  private

  def body_params(request)
    Oj.load(request.encoded_body)
  end
end
