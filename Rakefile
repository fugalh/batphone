task :doc => :rdoc

task :install do |t|
  sh 'ruby setup.rb'
end

task :dist do 
  sh 'darcs dist -d batphone-`cat VERSION`'
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  files = ['README', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "Batphone"
  rdoc.template = "theme/allison/allison.rb"
  rdoc.rdoc_dir = 'doc' # rdoc output folder
  rdoc.options << '--line-numbers' << '--inline-source'
end

task :sync => [:dist, :rdoc] do
  sh 'rsync -av ./ falcon:public_html/src/batphone/'
end

task :default => :rdoc
