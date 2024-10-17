require 'redis'
require 'json'

class Runner
  TAGS_LOCKED_NAME = 'tags:locked'.freeze

  def initialize
    @redis = Redis.new
  end

  def exec_actions
    worker_loop
  end

  private

  def get_next_available_job
    loop do
      job_json = @redis.lrange('jobs_queue', 0, -1).find do |job_json|
        job = JSON.parse(job_json)
        result = true
        @redis.smembers(TAGS_LOCKED_NAME).each do |s_tag|
          job['tags'].each do |tag|
            result = false if tag == s_tag
          end
        end
        result
      end

      if job_json
        job = JSON.parse(job_json)

        @redis.sadd(TAGS_LOCKED_NAME, *job['tags'])
        return { job: job, job_json: job_json }
      else
        sleep(0.5)
      end
    end
  end

  def complete_job(job)
    @redis.srem(TAGS_LOCKED_NAME, *job["tags"])
  end

  def process_job(job)
    puts "Processing job: #{job['id']}"
    class_const = Object.const_get(job['class'])
    case job['attributes'].class
    when Array then class_const.call(*job['attributes'])
    when Hash then class_const.call(**job['attributes'])
    else class_const.call
    end

    puts "Job completed: #{job['id']}"
  end

  def worker_loop
    loop do
      job_data = get_next_available_job
      if job_data
        job, job_json = job_data[:job], job_data[:job_json]
        process_job(job)
        complete_job(job)
        @redis.lrem('jobs_queue', 0, job_json)
      else
        sleep(1)
      end
    end
  end
end
