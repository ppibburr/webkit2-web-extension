require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'webkit2-web-extension', 'version'))

Gem::Specification.new do |gem|
  gem.name    = 'webkit2-web-extension'
  gem.version = WebKit2WebExtension::VERSION::STRING
  gem.date    = Date.today.to_s

  gem.summary = "Ruby bindings to WebKit2WebExtension (gtk)"
  gem.description = "Write WebKit2Gtk WebExtensions in ruby"

  gem.authors  = ['ppibburr']
  gem.email    = 'tulnor33@gmail.com'
  gem.homepage = 'http://github.com/ppibburr/webkit2-web-extension'

  gem.add_dependency('rake')
  gem.add_dependency('webkit2-gtk')
  
  # ensure the gem is built out of versioned files
  gem.files = (Dir['Rakefile', '{bin,lib,man,test,spec, ext}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")).push(*Dir.glob("./ext/*.so"))
  
  gem.require_paths = ["lib"]
end
