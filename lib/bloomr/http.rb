# frozen_string_literal: true

module Bloomr
  module Auth
    def http
      @http ||= Faraday.new do |f|
        f.request  :url_encoded
        f.response :logger
        f.response :raise_error
        f.adapter  Faraday.default_adapter
      end
    end

    def auth_request(path, method, params = {}, headers = {})
      url = auth_url(path)
      process(url, method, params, headers)
    end

    def request(path, method, params = {}, headers = {})
      url = api_url(path)
      process(url, method, params, headers)
    end

    def process(url, method, params, headers)
      url, body = parse_url_and_body(method, url, params, headers)

      msg = { type: :request, method:, url:, body:, headers: }

      log(Bloomr::LEVEL_INFO, msg)

      response = run_request_with_error url do
        http.run_request(method, url, body, headers)
      end

      log(Bloomr::LEVEL_INFO, type: :response, response: response)

      JSON.parse(response.body, symbolize_names: true)
    end

    private

    def api_url(path = '')
      @api_url_base + path
    end

    def auth_url(path = '')
      @auth_url_base + path
    end

    def parse_url_and_body(method, url, params, headers)
      body = nil

      case method
      when :get, :head, :delete
        query = params.map { |k, v| "#{k}=#{v}" }.join('&')
        url += "#{URI.parse(url).query ? '&' : '?'}#{query}"
      else
        if headers['Content-Type'] == 'application/x-www-form-urlencoded'
          body = URI.encode_www_form(params)
        else
          body = params.to_json
        end
      end

      [url, body]
    end

    def run_request_with_error(url)
      yield
    rescue StandardError => e
      case e
      when Faraday::ClientError
        if e.response
          handle_error_response(e.response)
        else
          handle_network_error(e, url)
        end
      else
        raise
      end
    end

    def handle_error_response(resp)
      p resp
      message = resp[:body].to_s
      log Bloomr::LEVEL_ERROR, message
      raise HttpError, message
    end

    def handle_network_error(err, url = nil)
      case err
      when Faraday::ConnectionFailed
        message = 'Unexpected error communicating when trying to connect' \
        " to Bloom Server (#{url}). You may be seeing this message because " \
        'your DNS is not working.'

      when Faraday::SSLError
        message = 'Could not establish a secure connection to ' \
        'Bloom Server, you may need to upgrade your OpenSSL version.'

      when Faraday::TimeoutError
        host ||= @api_base
        message = "Could not connect to Bloom Server (#{host}). " \
        'Please check your internet connection and try again. ' \
        'If this problem persists, let us know.'

      else
        message = 'Unexpected error communicating with Bloom. ' \
        'If this problem persists, let us know.'
      end

      log Bloomr::LEVEL_ERROR, message
      raise HttpError, message + "\n\n(Network error: #{err.message})"
    end

    def log(level, message = '', out = $stderr)
      return unless Bloomr.debug

      if !Bloomr.logger.nil?
        Bloomr.logger.log(level, message)
      else
        out.puts format('message=%<message>s level=%<level>s',
                        message: message, level: level)
      end
    end
  end
end
