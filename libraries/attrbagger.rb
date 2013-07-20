# vim:fileencoding=utf-8

require 'chef/mash'
require 'chef/mixin/deep_merge'

class Attrbagger
  def initialize(options = {})
    @context = options.fetch(:context)
    @data_bag = options.fetch(:data_bag)
    @base_config = options.fetch(:base_config)
    @env_config = options.fetch(:env_config)
  end

  def load_config
    Chef::Mixin::DeepMerge.merge(
      load_base_config,
      load_env_config
    )
  end

  private
  def load_base_config
    load_data_bag_item(@base_config)
  end

  def load_env_config
    load_data_bag_item(@env_config)
  end

  def load_data_bag_item(item_name)
    @context.data_bag_item(@data_bag, item_name).reject do |key,_|
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
