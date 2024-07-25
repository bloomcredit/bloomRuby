# frozen_string_literal: true

RSpec.describe Bloomr do
  it "has a version number" do
    expect(Bloomr::VERSION).not_to be nil
  end

  it "does something useful" do
    # Bloomr.debug = true
    api = Bloomr::Api.new(
      api_url_base: 'https://sandbox.bloom.dev',
      auth_url_base: 'https://auth.bloom.dev',
      client_id: 'client_id',
      client_secret: 'client_secret_key'
    )
    token = api.fetch_auth_token
    # id = api.register_consumer(token, {
    #   'first_name' => 'Michael',
    #   'last_name' => 'Scott',
    #   'city' => 'Scranton',
    #   'line1' => '1725 Slough Avenue',
    #   'state_code' => 'PA',
    #   'zipcode' => '18503',
    #   "address_primary" => true,
    #   'date_of_birth' => '1964-03-15',
    #   "ssn" => "123456789"
    # })
    # p id
    api.get_credit_data(token, 1)
  end
end
