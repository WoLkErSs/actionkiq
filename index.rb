require_relative './lib/autoload/autoload.rb'

shutdown = false
$paused = false
threads = []

def worker_thread(id)
  loop do
    if $paused
      puts "Thread #{id} is $paused."
      while $paused
        break if Thread.current[:shutdown]

        sleep(1)
      end
    end

    break if Thread.current[:shutdown]

    puts "Thread #{id} is working"
    Worker.run(ARGV)
  end
  puts "Thread #{id} has been shut down"
end

Signal.trap('SIGTERM') do
  puts 'SIGTERM - shutting down'
  shutdown = true
  threads.each { |thread| thread[:shutdown] = true }
end

Signal.trap('SIGINT') do
  puts 'SIGINT - shutting down'
  shutdown = true
  threads.each { |thread| thread[:shutdown] = true }
end

Signal.trap('SIGTSTP') do
  puts 'SIGTSTP - pausing new actions'
  $paused = true
end

Signal.trap('SIGUSR2') do
  puts 'SIGUSR2 - resuming new actions'
  $paused = false
end

ENV['THREADS_POOL'].to_i.times do |i|
  threads << Thread.new do
    worker_thread(i)
  end
end

threads.each(&:join)

puts 'Programm has been shut down'
