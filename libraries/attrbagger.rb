# vim:fileencoding=utf-8

require 'chef/mash'
require 'chef/mixin/deep_merge'

class Attrbagger
  def initialize(options = {})
    @context = options.fetch(:context)
    if options[:bag_cascade]
      @bag_cascade = options[:bag_cascade]
    else
      @bag_cascade = %W(
        #{options.fetch(:data_bag)}:#{options.fetch(:base_config)}
        #{options.fetch(:data_bag)}:#{options.fetch(:env_config)}
      )
    end
  end

  def load_config
    Chef::Mixin::DeepMerge.merge(
      *(@bag_cascade.map { |s| load_data_bag_item_from_string(s) })
    )
  end

  private
  def load_data_bag_item_from_string(bag_string)
    bag_name, item_name = bag_string.split(':')
    load_data_bag_item(bag_name, item_name)
  end

  def load_data_bag_item(bag_name, item_name)
    @context.data_bag_item(bag_name, item_name).reject do |key,_|
      %(id chef_type data_bag).include?(key)
    end
  rescue StandardError => e
    unless ENV['QUIET']
      $stderr.puts "#{e.class.name} #{e.message}"
    end
    @context.log(e) { level :error }
    {}
  end
end
