require 'webkit2-web-extension/ipc/io-util'

module WebKit2WebExtension
  module IPC
    DEFAULT_SOCKET_PATH = "/tmp/rb-#{Process.pid}.sock"

    class Service
      include IOUtil
      
      attr_reader :srv, :socket_path, :clients
      
      def initialize path, &b
        File.unlink(path) if File.exists?(path)

        @srv = UNIXServer.new @socket_path=path
        
        at_exit {
          p :EXIT
          File.delete(path)
        }

        @clients = []

        b.call self if b

        GLib::Idle.add do
          begin
            if s = srv.accept_nonblock;
              clients << s
              @accept.call s if @accept
            end
          rescue IO::EAGAINWaitReadable;
          end
          true
        end
        
        GLib::Idle.add do
          clients.each do |c|
            read_non_block c do |data|
              message(data, c) unless data.empty?
            end
          end
          
          true
        end
      end;
      
      def accept s=nil, &b
        @accept = b if b
        @accept.call(s) if s && !b && @accept
      end 
    end
  end
  
  def self.ipc_service socket_file = nil, &b
    return @ips if @ips && !socket_file
    
    if !socket_file
      @ips = IPC::Service.new(socket_file = IPC::DEFAULT_SOCKET_PATH, &b)
    else
      IPC::Service.new(socket_file, &b)
    end
  end  
  
  def self.ipc?()
    !!@ips
  end
end
