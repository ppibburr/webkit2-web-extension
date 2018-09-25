require "gobject-introspection"
require 'json'

begin
  module WebKit2WebExtension
    class << self
      def const_missing(name)
        init
        if const_defined?(name)
          const_get(name)
        else
          super
        end
      end

      def init
        class << self
          remove_method(:init)
          remove_method(:const_missing)
        end
        
        loader = GObjectIntrospection::Loader.new(self)
        loader.load("WebKit2WebExtension")
      end
    end
      
    class Extension
      attr_reader :sw, :ppid, :program, :data

      def initialize
        obj   = JSON.parse(ARGV.shift) unless ARGV.empty?
        
        prog  = obj['extension'] if obj
        @ppid = obj['ppid']      if obj
        @data = obj['data']      if obj
         
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
      
      def clear pg = nil, f = nil, main = false, &b
        @clear = b        if b and !pg
        @clear.call pg, f, main if !b and @clear and pg
      end
      
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
      
      def document_loaded pg = nil, &b
        @doc_load.call(pg, pg.main_frame) if pg and !b and @doc_load
        @doc_load = b                     if b and !pg
      end
      
      def message pg=nil, msg=nil, &b
        unless b
          @msg.call pg, msg if msg and @msg
        end
        
        @msg = b if b
      end
      
      def run
        p({:load => program}) if program
        load program          if program      
      end
      
      def self.default
        @ins ||= new
      end
    end

    def self.default
      Extension.default  
    end
  end
rescue => e; 
  puts e
  puts e.backtrace.join("\n")
end
