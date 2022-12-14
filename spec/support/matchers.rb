# frozen_string_literal: true

RSpec::Matchers.define :have_body_params do |params|
  match do |request|
    body = body_params(request)

    values_match?(params, body)
  end
  failure_message do |request|
    super() + ", but had #{body_params(request)}"
  end
  failure_message_when_negated do |request|
    super() + ", but had #{body_params(request)}"
  end

  private

  def body_params(request)
    Oj.load(request.encoded_body, mode: :compat)
  end
end

RSpec::Matchers.define :have_query_params do |params|
  match do |request|
    body = fetch_uri_params(request)

    values_match?(params, body)
  end
  failure_message do |request|
    super() + ", but had #{fetch_uri_params(request)}"
  end
  failure_message_when_negated do |request|
    super() + ", but had #{fetch_uri_params(request)}"
  end

  private

  # TODO: This method is also used in spec/doubles/base.rb. Where can we put it
  #       to safely re-use it in both locations? Imo matchers.rb and spec/doubles/base.rb
  #       on their own do not have a relationship. matchers.rb can be used outside of doubles
  #       tests and doubles tests do not peek into the private methods of custom matchers.
  #       So, it probably has to be defined somewhere globally within rspec?
  def fetch_uri_params(request)
    URI.parse(request.url).query.split('&').map { |pair| pair.split('=') }.to_h
  end
end
