require 'redis'
require 'json'
require 'pry'
require 'rack'
require 'securerandom'

module Middlewares
  class Actionkiq
    def self.call(env)
      new(env).response.finish
    end

    def initialize(env)
      @request = Rack::Request.new(env)
    end

    def response
      if @request.env['REQUEST_METHOD'] == 'POST' && @request.path == '/action'
        @redis = Redis.new
        @redis.lpush('jobs_queue', { id: ::SecureRandom.uuid, tags: @request.params['tags'] }.to_json)
        Rack::Response.new('created', 200, { 'Content-Type' => 'text/plain' })
      else
        Rack::Response.new('Not Found', 404)
      end
    end
  end
end
