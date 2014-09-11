require "socket"

if Gem::Platform.local.os == "darwin"
  current_path = "/Users/zxy/current"
  command_path = "/Users/zxy/command"
else
  current_path = "/root/current"
  command_path = "/root"
end

def net_status
  File.open "/Users/zxy/current" do |f|
    return f.read
  end
end

port = 12321
server = TCPServer.new port

loop do
  client = server.accept
  command = client.gets.chomp.strip
  client_ip = client.addr[3]
  if client_ip =~ /192.168.\d{1,2}.100/ 
    num = client_ip.split(".")[2]
  else
    num = 0
  end
  if command == "net"
    fpath = command_path+"/net"+num.to_s
    client.puts  "ok"
  elsif command == "school"
    fpath = command_path+"/school"
    client.puts  "ok"
  elsif command == "current"
    client.puts net_status
  end
  client.close
end
