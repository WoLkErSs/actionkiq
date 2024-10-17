require_relative './lib/autoload/autoload.rb'
threads = []
ENV['THREADS_POOL'].to_i.times do
  threads << Thread.new do
    Runner.new.exec_actions
  end
end
threads.each(&:join)
