desc "build webkit2-web-extension ruby loader extension"
task :ext do  
  sh 'cd ext && gcc -g ./rb-webkit2-web-extension.c $(pkg-config --cflags --libs ruby-2.3) $(pkg-config --cflags --libs webkit2gtk-web-extension-4.0) -o extension.so -fPIC -shared'
end

desc 'Build gem'
task :gem do
  sh 'gem build webkit2-web-extension.gemspec' 
end

desc 'Installs gem'
task :install do
  sh "gem i -l webkit2-web-extension*.gem"
end

desc 'Run sample'
task :sample do
  sh "ruby #{File.join(File.dirname(__FILE__), 'sample', 'webview.rb')}"
end
