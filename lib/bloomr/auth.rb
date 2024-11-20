# frozen_string_literal: true

module Bloomr
  module Auth
    def fetch_auth_token
      raise Error.new 'Make sure client_id is set' unless client_id
      raise Error.new 'Make sure client_secret is set' unless client_secret

      body = {
        client_id: client_id,
        client_secret: client_secret,
        audience: 'dev-api',
        scope: 'data-access:all',
        grant_type: 'client_credentials'
      }

      headers = {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }

      auth_request('/oauth2/token', :post, body, headers)[:access_token]
    end
  end
end
