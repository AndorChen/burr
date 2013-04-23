if RUBY_VERSION < '1.9.3'
  $stderr.puts "Your Ruby version(#{RUBY_VERSION}) is NOT supported, please upgrade!"
  exit 1
end
