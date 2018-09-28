require 'socket'

module WebKit2WebExtension
  module IPC
    module IOUtil
      def read_non_block io, &b  
        if result = IO.select([io],[],[],0)
          data = result[0][0].gets
          
          b.call data if b
        end
      rescue IO::EAGAINWaitReadable;   
      end
      
      def message m=nil,c=nil, &b
        @msg = b if b
        
        if c && m && !b && @msg
          o = [m]
          o << c if @msg.arity > 1 
        
          @msg.call *o
        end
      end  
    end
  end
end
