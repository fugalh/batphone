task :rdoc => :doc
task :doc do |t|
  sh 'rdoc -t "Batphone" -m README README lib'
end

task :install do |t|
  sh 'ruby setup.rb'
end

task :dist do 
  sh 'darcs dist -d batphone-`cat VERSION`'
end

task :default => :rdoc
