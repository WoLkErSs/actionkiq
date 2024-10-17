require 'redis'
require 'json'
require 'pry'
require 'rack'

module Middlewares
  class Actionkiq
    def self.call(env)
      new(env).response.finish
    end

    def initialize(env)
      @request = Rack::Request.new(env)
    end

    def response
      binding.pry
      # @redis.lpush('jobs_queue', {id: 'ididid', tags: ['test'], class: 'Worker', attributes: {awd: 'Attribut for Worker'}}.to_json)
      if @request.path == '/'
        Rack::Response.new('Hello, world!', 200, { 'Content-Type' => 'text/plain' })
      else
        Rack::Response.new('Not Found', 404)
      end
    end
  end
end
