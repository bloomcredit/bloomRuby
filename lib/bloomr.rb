# frozen_string_literal: true

require 'logger'
require 'faraday'
require 'uri'
require 'csv'

require_relative "bloomr/version"
require_relative "bloomr/http"
require_relative "bloomr/auth"
require_relative "bloomr/consumer"
require_relative "bloomr/credit"
require_relative "bloomr/api"

module Bloomr
  @debug = false
  @logger = nil

  LEVEL_DEBUG = Logger::DEBUG
  LEVEL_ERROR = Logger::ERROR
  LEVEL_INFO = Logger::INFO

  class << self
    attr_accessor :debug, :logger
  end

  class Error < StandardError; end
  class HttpError < Error; end
  class InputError < Error; end
end
