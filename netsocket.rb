#encoding: utf-8
require "socket"

if Gem::Platform.local.os == "darwin"
  CurrentPath = "/Users/zxy/current"
  command_path = "/Users/zxy/command"
else
  CurrentPath = "/root/current"
  command_path = "/root"
end

def net_status
  File.open CurrentPath do |f| 
    return f.read
  end
end

port = 12321
server = TCPServer.new port

loop do 
  Thread.start(server.accept) do |client|
    loop do 
      client_ip = client.peeraddr[3]
      if client_ip =~ /192.168.\d{1,2}.100/ 
        num = client_ip.split(".")[2].to_i
      else
        num = 0
      end
      command = client.gets.chomp.strip
      cstatus = net_status.chomp.strip
      if command == "net"
        if cstatus.include?("net") 
          fpath = command_path+"/allnet"
        else
          fpath = command_path+"/net"+num.to_s
        end
        %x(#{fpath}) if File.exist?(fpath)
        client.puts $?==0 ? "net_ok" : "net_error"
        client.flush
      elsif command == "school"
        neibor_num = num%2==0 ? num-1 : num+1
        if cstatus.include?("net") and cstatus!="net"+num.to_s
          fpath = command_path+"/net"+neibor_num.to_s
        else
          fpath = command_path+"/school"
        end
        %x(#{fpath}) if File.exist?(fpath)
        client.puts $?==0 ? "school_ok" : "school_error"
        client.flush
      elsif command == "current"
        client.puts net_status.chomp.strip	
        client.flush
        puts "current status is "+net_status
      elsif command == "close"
        puts "#{client_ip} closed"
        client.close
        break
      end
    end
  end
end
