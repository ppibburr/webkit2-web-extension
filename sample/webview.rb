require 'webkit2-web-extension/config'

WebKit2WebExtension.config extension: File.expand_path(File.join(File.dirname(__FILE__), 'extension', 'extension.rb')),
                           data:      {foo: 5}
                           
w = Gtk::Window.new
w.add wv = WebKit2Gtk::WebView.new()

w.resize 680,400

w.show_all

w.signal_connect "delete-event" do
  Gtk.main_quit
end

wv.load_html "<html><body>check your console</body></html>", ""

Gtk.main
