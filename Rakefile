task :install do
  sh 'bundle install'
end

task :default do
  sh 'bundle exec ruby simple-calculate.rb'
end

task :test do
  Dir.glob('./test/*[\._]test.rb').each { |file| require file }
end
