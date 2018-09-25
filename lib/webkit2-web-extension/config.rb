$: << File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'webkit2-gtk'
require 'webkit2-web-extension/version'
require 'json'

module WebKit2WebExtension
  # Call immediately!
  #
  # @param [Hash] o options
  # @option o [String] :extensions_path the path to tell WebKit2Gtk::WebContext where to find extensions, defaults to `<gem_dir>/ext`
  # @option o [String] :extension the ruby file to load in WebProcess, defaults to `./extension.rb`
  # @option o [Object#to_json] :initialization_data for the extension, defaults to `{}`
  #
  # @return [Hash] config 
  def self.config o={}
    default = {
      extensions_path: File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'ext')),
      extension:       './extension.rb',
      data:            {}
    }
    
    p opts = default.merge(o)

    ctx = WebKit2Gtk::WebContext.default()
    ctx.set_web_extensions_directory(opts[:extensions_path]);
    
    ctx.signal_connect "initialize-web-extensions" do
      ctx.web_extensions_initialization_user_data = GLib::Variant.new({ppid: Process.pid, extension: opts[:extension], data: opts[:data]}.to_json)
    end
    
    opts
  end

  # @!visibility private  
  def self.init_webview(wv)
    wv.run_javascript('true;') do |wv,r|
      wv.run_javascript_finish r
    end  
    
    wv
  end
end

WebKit2Gtk::WebView

# @!visibility private
class WebKit2Gtk::WebView
  # @!visibility private
  class << self
    alias :_web_view_new :new
  end
  
  # @!visibility private
  def self.new *o
    wv = _web_view_new *o
    WebKit2WebExtension.init_webview(wv)
  end
end
