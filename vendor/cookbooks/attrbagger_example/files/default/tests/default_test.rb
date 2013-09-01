require 'minitest/spec'

describe_recipe 'attrbagger_example::default' do
  it 'creates the buzz file with the right number' do
    ::File.read("#{Chef::Config[:file_cache_path]}/buzz").chomp.must_equal '7'
  end
end
