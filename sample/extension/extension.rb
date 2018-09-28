ipc = WebKit2WebExtension.ipc_client do |c|
  c.message do |m|
    puts cli_rcv_msg: JSON.parse(m)
    c.puts '{"go": "away"}'
  end
end

ext = WebKit2WebExtension.default

# called when a page main frame is cleared the +first time+
ext.init do |pg|
  p init: pg
end

# Called when a frame is cleared
ext.clear do |pg, fr, is_main|
  p clear: {page: pg, frame: fr, is_main: is_main}
end

# called when frame document loaded
ext.document_loaded do |pg, fr|
  p(on_ready: {pg: pg, frame: fr})
end

# Called on console.log
ext.message do |pg, msg|
  ipc.puts({console_message: {page: pg.id, text: msg.text}}.to_json)
end

p initialization_data: ext.initialization_data

