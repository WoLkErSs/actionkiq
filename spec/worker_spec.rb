require "spec_helper"

describe Worker do
  let(:redis) { MockRedis.new }

  describe '.run' do
    context 'skips locked tags' do
      let(:locked_tag) { 'locked' }
      let(:active_tag) { 'active' }
      let(:locked_task) { { id: ::SecureRandom.uuid, tags: [locked_tag] }.to_json }
      let(:active_task) { { id: ::SecureRandom.uuid, tags: [active_tag] }.to_json }

      before do
        allow(Redis).to receive(:new).and_return(redis)
        redis.lpush(Worker::MAIN_QUEUE, locked_task)
        redis.lpush(Worker::MAIN_QUEUE, active_task)
        redis.sadd(Worker::TAGS_LOCKED_NAME, locked_tag)
      end

      it 'has skippe locked tags' do
        expect(redis.lrange(Worker::MAIN_QUEUE, 0, -1)).to include(locked_task)
        Worker.run
        expect(redis.lrange(Worker::MAIN_QUEUE, 0, -1)).to include(locked_task)
      end

      it 'has pocess active jobs' do
        expect(redis.lrange(Worker::MAIN_QUEUE, 0, -1)).to include(active_task)
        Worker.run
        expect(redis.lrange(Worker::MAIN_QUEUE, 0, -1)).not_to include(active_task)
      end
    end
  end
end
