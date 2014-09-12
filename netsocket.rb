require "socket"

if Gem::Platform.local.os == "darwin"
  CurrentPath = "/Users/zxy/current"
  command_path = "/Users/zxy/command"
else
  CurrentPath = "/root/current"
  command_path = "/root"
end

def net_status
  if File.exist?(CurrentPath)
    File.open CurrentPath do |f| 
      return f.read
    end
  else
    return "文件不存在"
  end
end

port = 12321
server = TCPServer.new port
client = server.accept

loop do
  client_ip = client.addr[3]
  if client_ip =~ /192.168.\d{1,2}.100/ 
    num = client_ip.split(".")[2]
  else
    num = 0
  end
  command = client.gets.chomp.strip
  if command == "net"
    if net_status.include?("net")
      fpath = command_path+"/allnet"
    else
      fpath = command_path+"/net"+num.to_s
    end
    %x(#{fpath}) if File.exist?(fpath)
    client.puts $?==0 ? "ok" : "error"
  elsif command == "school"
    fpath = command_path+"/school"
    %x(#{fpath}) if File.exist?(fpath)
    client.puts $?==0 ? "ok" : "error"
  elsif command == "current"
    client.puts net_status
  elsif command == "close"
    puts "#{client_ip} closed"
    client.close
    client = server.accept
  else
    client.puts command
  end
end
