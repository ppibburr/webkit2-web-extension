require "gobject-introspection"
require 'json'

require 'webkit2-web-extension/ipc'

module WebKit2WebExtension
  class << self
    # @!visibility private
    def const_missing(name)
      init
      if const_defined?(name)
        const_get(name)
      else
        super
      end
    end

    # @!visibility private
    def init
      class << self
        remove_method(:init)
        remove_method(:const_missing)
      end
      
      loader = GObjectIntrospection::Loader.new(self)
      loader.load("WebKit2WebExtension")
    end
  end
    
  # Extension object  
  #
  # Provides mechanisms to access {WebKit2WebExtension::Page}'s 
  class Extension
    attr_reader :sw, :ppid, :program, :data, :initialization_data, :ipc_socket_path

    def initialize
      @initialization_data = obj = JSON.parse(ARGV.shift) unless ARGV.empty?
      
      prog             = obj['extension']       if obj
      @ppid            = obj['ppid']            if obj
      @data            = obj['data']            if obj
      @ipc_socket_path = obj['ipc_socket_path'] if obj
       
      puts "Extension initialization data => #{obj}" 
       
      if prog and File.exist?(prog)
      elsif File.exist?(prog=File.join(ENV['HOME'], '.webkit2-web-extension', 'extensions', prog, "extension.rb"))
      end
      
      unless prog
        if File.exist?(prog="./extension.rb")
        elsif File.exist?(prog=File.join(ENV['HOME'], '.webkit2-web-extension', 'extensions', 'default', "extension.rb"))
        end
      end      
    
      @program = prog
    
      @sw = WebKit2WebExtension::ScriptWorld.default

      sw.signal_connect "window-object-cleared" do |_,pg,f|
        init(pg) if main = f.main_frame?
        
        clear(pg, f, main)
      end
    end
    
    # @param [Proc] &b when called with block, registers signal on +window-object-cleared+ of any frame of any page
    #
    # @yieldparam [WebKit2WebExtension::WebPage] pg the page the frame belongs to
    # @yieldparam [WebKit2WebExtension::Frame] frame the frame that was cleared
    # @yieldparam [Boolean] main true if the frame is the +#main_frame+ of +page+       
    def clear pg = nil, f = nil, main = false, &b
      @clear = b        if b and !pg
      @clear.call pg, f, main if !b and @clear and pg
    end
    
    # @param [Proc] &b when called with block, registers signal on +window-object-cleared+ of +#main_frame+ of a page, the first time only
    #
    # @yieldparam [WebKit2WebExtension::WebPage] pg
    def init pg = nil, &b
      if !@_init_ and pg
        pg.signal_connect "document-loaded" do
          document_loaded pg
        end
        
        pg.signal_connect 'console-message-sent' do |_, msg|
          message pg, msg
        end
        
        @init.call pg if !b and @init
        @_init_ = true
      end
      
      @init = b if b and !pg 
    end
    
    # @param [Proc] &b when called with block, registers signal on +document-loaded+ of the +#main_frame+ of any page
    #
    # @yieldparam [WebKit2WebExtension::WebPage] pg the page the frame belongs to
    # @yieldparam [WebKit2WebExtension::Frame]   frame the main_frame of +pg+
    def document_loaded pg = nil, &b
      @doc_load.call(pg, pg.main_frame) if pg and !b and @doc_load
      @doc_load = b                     if b and !pg
    end
    
    
    # @param [Proc] &b when called with block, registers signal on +console-message-sent+ of any page
    #
    # @yieldparam [WebKit2WebExtension::WebPage] pg the page the message belongs to
    # @yieldparam [WebKit2WebExtension::Frame]   msg the message 
    def message pg=nil, msg=nil, &b
      unless b
        @msg.call pg, msg if msg and @msg
      end
      
      @msg = b if b
    end
    
    # @!visibility private
    def run
      p({:load => program}) if program
      load program          if program      
    end
    
    # @!visibility private
    def self.default
      @ins ||= new
    end
  end

  # Main access point of extension program
  # 
  # @return [WebKit2WebExtension::Extension] the extension of process
  def self.default
    Extension.default  
  end
end
