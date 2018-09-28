require 'webkit2-web-extension/config'

WebKit2WebExtension.ipc_service do |srv|
  srv.accept do |c|
    p ipc_accept: c
    c.puts '{"value": "ACCEPT"}'
  end
  
  srv.message do |m, c|
    p(ipc_srv_rcv_msg: {client: c, message: JSON.parse(m)})
    c.puts '{"no": "way"}'
  end 
end

WebKit2WebExtension.config extension: File.expand_path(File.join(File.dirname(__FILE__), 'extension', 'extension.rb')),
                           data:      {foo: 5}
                           
w = Gtk::Window.new
w.add wv = WebKit2Gtk::WebView.new()
wv.run_javascript('console.log("Hello!");') do |wv,r|
  wv.run_javascript_finish(r)
end
w.resize 680,400

w.show_all

w.signal_connect "delete-event" do
  Gtk.main_quit
end

Gtk.main
