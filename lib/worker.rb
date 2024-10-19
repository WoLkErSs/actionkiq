class Worker
  TAGS_LOCKED_NAME = 'tags:locked'.freeze

  def self.run(target_tags)
    new(target_tags).exec
  end

  def initialize(target_tags=[])
    @target_tags = target_tags
    @redis = Redis.new
  end

  def exec
    job_data = get_next_available_job
    if job_data
      job, job_json = job_data[:job], job_data[:job_json]
      process_job(job)
      @redis.srem(TAGS_LOCKED_NAME, *job["tags"])
      @redis.lrem('jobs_queue', 0, job_json)
    end
  end

  private

  def get_next_available_job
    job_json = @redis.lrange('jobs_queue', 0, -1).find do |job_json|
      job = JSON.parse(job_json)
      next if !@target_tags.empty? && !no_tags_overlapped?(@target_tags, job['tags'])

      no_tags_overlapped?(@redis.smembers(TAGS_LOCKED_NAME), job['tags'])
    end
    return nil unless job_json

    job = JSON.parse(job_json)
    @redis.sadd(TAGS_LOCKED_NAME, *job['tags'])
    { job: job, job_json: job_json }
  end

  def no_tags_overlapped?(data_tags, tags)
    data_tags.each do |s_tag|
      tags.each do |tag|
        return false if tag == s_tag
      end
    end
    true
  end

  def process_job(job)
    puts "Processing job: #{job['id']}"
    sleep(rand(0..3))
    puts "Job completed: #{job['id']}"
  end
end
