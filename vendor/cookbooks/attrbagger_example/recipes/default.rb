file "#{Chef::Config[:file_cache_path]}/buzz" do
  action :delete
end

new_content = node['flurb']['foop']['buzz']

file "#{Chef::Config[:file_cache_path]}/buzz again!" do
  path "#{Chef::Config[:file_cache_path]}/buzz"
  content "#{new_content}"
end
