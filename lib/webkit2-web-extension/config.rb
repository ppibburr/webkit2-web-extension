$: << File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'webkit2-gtk'
require 'webkit2-web-extension/version'
require 'json'

module WebKit2WebExtension
  # Call immediately!
  def self.config o={}
    default = {
      extensions_path: File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'ext')),
      extension:       './extension.rb',
      data:            {}
    }
    
    opts = default.merge(o)

    ctx = WebKit2Gtk::WebContext.default()
    ctx.set_web_extensions_directory(opts[:extensions_path]);
    
    ctx.signal_connect "initialize-web-extensions" do
      ctx.web_extensions_initialization_user_data = GLib::Variant.new({ppid: Process.pid, extension: opts[:extension], data: opts[:data]}.to_json)
    end
  end
  
  def self.init_webview(wv)
    wv.run_javascript('true;') do |wv,r|
      wv.run_javascript_finish r
    end  
    
    wv
  end
end

WebKit2Gtk::WebView
class WebKit2Gtk::WebView
  class << self
    alias :_web_view_new :new
  end
  
  def self.new *o
    wv = _web_view_new *o
    WebKit2WebExtension.init_webview(wv)
  end
end
