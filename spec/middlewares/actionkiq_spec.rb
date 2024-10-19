require "spec_helper"
require './middlewares/actionkiq'

describe Middlewares::Actionkiq do
  include Rack::Test::Methods

  let(:redis) { MockRedis.new }

  def app
    Rack::Builder.parse_file('config.ru')
  end

  before do
    allow(Redis).to receive(:new).and_return(redis)
  end

  context 'with rack env' do
    it 'returns ok status' do
      expect(redis.lrange(Worker::MAIN_QUEUE, 0, -1)).to be_empty
      post '/action', { 'tags' => 'active' }
      expect(redis.lrange(Worker::MAIN_QUEUE, 0, -1)).not_to be_empty
      expect(last_response.status).to eq(200)
    end
  end
end
