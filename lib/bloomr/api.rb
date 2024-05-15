# frozen_string_literal: true

module Bloomr
  class Api
    attr_reader :api_url_base, :auth_url_base, :client_id, :client_secret

    include Auth
    include Consumer
    include Credit

    def initialize(api_url_base:, auth_url_base:, client_id:, client_secret:)
      @api_url_base = api_url_base
      @auth_url_base = auth_url_base
      @client_id = client_id
      @client_secret = client_secret
    end
  end
end
