# vim:fileencoding=utf-8

require 'chef/mash'
require 'chef/log'
require 'chef/mixin/deep_merge'
require 'chef/resource_collection'

class Attrbagger
  include Chef::DSL::DataQuery

  class << self
    def autoload!(run_context)
      run_context.node['attrbagger']['configs'].each do |key, bag_cascade|
        bag_config = Attrbagger.new(
          context: run_context, bag_cascade: bag_cascade
        ).load_config

        if bag_config && !bag_config.empty?
          precedence_level = run_context.node.send(
            run_context.node['attrbagger']['precedence_level'] || :override
          )

          assignment_level = fetch_key_for_keyspec(key, run_context.node)
          new_value = bag_config
          if assignment_level
            new_value = Chef::Mixin::DeepMerge.merge(
              assignment_level, bag_config
            )
          end

          assign_to_keyspec(precedence_level, key, new_value)
        end
      end
    end

    def fetch_key_for_keyspec(keyspec, bag_item)
      if !keyspec
        return bag_item
      end
      lookup = keyspec.split('::')
      nlevel = 0
      item_level = bag_item
      while key = lookup[nlevel]
        item_level = item_level[key] || {}
        nlevel += 1
      end
      item_level
    end

    def assign_to_keyspec(hashlike, keyspec, value)
      lookup = keyspec.split('::')
      key = lookup.pop
      hash_level = hashlike
      if !lookup.empty?
        hash_level = fetch_key_for_keyspec(lookup.join('::'), hash_level)
      end
      hash_level[key] = value
    end
  end

  attr_reader :bag_cascade

  def initialize(options = {})
    @context = options.fetch(:context)
    if options[:bag_cascade]
      @bag_cascade = options[:bag_cascade]
    else
      @bag_cascade = [
        "data_bag[#{options.fetch(:data_bag)}::#{options.fetch(:base_config)}]",
        "data_bag[#{options.fetch(:data_bag)}::#{options.fetch(:env_config)}}]"
      ]
    end
  end

  def load_config
    top = Mash.new
    @bag_cascade.each do |s|
      bag_item = load_data_bag_item_from_string(s)
      if !bag_item || !bag_item.empty?
        top.merge!(Chef::Mixin::DeepMerge.merge(top, bag_item))
      end
    end
    top.empty? ? nil : top
  end

  private
  def load_data_bag_item_from_string(bag_string)
    if bag_string =~ /^(.+)\[(.+)\]$/
      if $1 == 'data_bag'
        bag, item, keyspec = $2.split('::', 3)
        self.class.fetch_key_for_keyspec(
          keyspec, load_data_bag_item(bag, item || bag)
        )
      else
        errlog("Only 'data_bag' resources are supported by Attrbagger, " <<
               "not #{$1.inspect}.")
        return {}
      end
    else
      errlog("Invalid resource specification string #{bag_string.inspect}.")
      nil
    end
  end

  def load_data_bag_item(bag_name, item_name)
    (data_bag_item(bag_name, item_name) || {}).reject do |key,_|
      %(id chef_type data_bag).include?(key)
    end
  rescue StandardError => e
    errlog("#{e.class.name} #{e.message}")
    {}
  end

  def errlog(msg)
    unless ENV['QUIET']
      $stderr.puts msg
      Chef::Log.error(msg)
    end
  end
end
