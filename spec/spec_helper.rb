chef_libraries = File.expand_path('../../libraries', __FILE__)
unless $LOAD_PATH.include?(chef_libraries)
  $LOAD_PATH.unshift(chef_libraries)
end

ENV['QUIET'] = '1'
