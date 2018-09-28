require 'webkit2-web-extension/ipc/io-util'

module WebKit2WebExtension
  module IPC
    class Client
      include IOUtil
     
      attr_reader :socket, :socket_path
      def initialize path, &b
        @socket = UNIXSocket.new(@socket_path=path)
      
        b.call self if b
        
        GLib::Idle.add do;
          read_non_block self.socket do |data|
            message(data, self.socket) unless data.empty?
          end
          
          true
        end
      end
      
      def write s
        socket.write s
      end
      
      def puts s
        @socket.puts s
      end
    end
  end
  
  def self.ipc_client socket_file = nil, &b
    return @ipc if @ipc && !socket_file
    
    if !socket_file
      @ipc = IPC::Client.new(Extension.default.ipc_socket_path, &b)
    else
      IPC::Client.new(socket_file, &b)
    end
  end  
end
