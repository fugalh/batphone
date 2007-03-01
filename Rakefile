task :rdoc => :doc
task :doc do |t|
  sh 'rdoc -t "Ruby AGI" -m README README lib'
end

task :install do |t|
  sh 'ruby setup.rb'
end

task :dist do 
  sh 'darcs dist -d ruby-agi-`cat VERSION`'
end

task :default => :rdoc
