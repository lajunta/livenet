require "socket"

server = TCPServer.new 12321

loop do
  client = server.accept
  client.puts "Hello!"
  client.puts "Time is #{Time.now}"
  client.close
end
