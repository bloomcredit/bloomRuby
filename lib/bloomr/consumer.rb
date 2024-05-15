# frozen_string_literal: true

module Bloomr
  module Consumer
    def register_consumer(token, consumer_info = {})
      required_fields = %w[
        first_name
        last_name
        city
        line1
        state_code
        zipcode
        address_primary
      ]
      required_fields.each do |k|
        raise InputError.new("Required field missing : #{k}") unless consumer_info.keys.include?(k)
      end

      addresses = [{
        city: consumer_info['city'],
        hash: consumer_info['hash'],
        line1: consumer_info['line1'],
        line2: consumer_info['line2'],
        primary: consumer_info['address_primary'],
        state_code: consumer_info['state_code'],
        type: consumer_info['address_type'],
        zipcode: consumer_info['zipcode']
      }.compact]

      emails = {
        email_address: consumer_info['email_address'],
        primary: consumer_info['email_primary'],
        type: consumer_info['email_type']
      }.compact

      name = {
        first_name: consumer_info['first_name'],
        middle_name: consumer_info['middle_name'],
        last_name: consumer_info['last_name'],
        generation_code: consumer_info['generation_code']
      }.compact

      phones = {
        phone_number: consumer_info['phone_number'],
        primary: consumer_info['phone_primary'],
        type: consumer_info['phone_type']
      }.compact

      attributes = {
        ssn: consumer_info['ssn'],
        addresses: addresses,
        date_of_birth: consumer_info['date_of_birth'],
        emails: emails,
        income: consumer_info['income'],
        ip_address: consumer_info['ip_address'],
        name: name,
        phones: phones
      }.compact

      body = {
        data: {
          type: 'consumers',
          attributes:
        }
      }

      headers = {
        'Authorization' => "Bearer #{token}",
        'Content-Type' => 'application/json'
      }

      response = request('/v2/core/consumers', :post, body, headers)
      response['data']['id']
    end
  end
end
