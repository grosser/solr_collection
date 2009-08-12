desc "Run all specs in spec directory"
task :default do
  options = "--colour --format progress --loadby --reverse"
  files = FileList['spec/**/*_spec.rb']
  system("spec #{options} #{files}")
end

begin
  project = 'solr_collection'
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = project
    gem.summary = "Wrapper for solr results sets then behaves/feels like will_paginate collection"
    gem.email = "grosser.michael@gmail.com"
    gem.homepage = "http://github.com/grosser/#{project}"
    gem.authors = ["Michael Grosser"]
    gem.add_dependency "will_paginate"
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end