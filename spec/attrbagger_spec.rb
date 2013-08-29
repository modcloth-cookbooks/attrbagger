require 'attrbagger'
require 'chef/mash'
require 'chef/mixin/deep_merge'

describe Attrbagger do
  let :loader_from_base_and_env do
    described_class.new(
      :context => run_context,
      :data_bag => data_bag_name,
      :base_config => base_config_name,
      :env_config => env_config_name
    )
  end

  let :loader_from_bag_cascade do
    described_class.new(
      :context => run_context,
      :bag_cascade => bag_cascade
    )
  end

  let(:data_bag_name) { 'rsyslog' }
  let(:base_config_name) { 'flurb' }
  let(:env_config_name) { 'flurb_demo' }
  let(:bag_cascade) { %w(rsyslog:flurb rsyslog:flurb_demo) }

  let :run_context do
    double('run_context').tap do |ctx|
      ctx.stub(:log)
      ctx.stub(:data_bag_item) do |_, config|
        case config
        when base_config_name
          base_data_bag_item_content
        when env_config_name
          env_data_bag_item_content
        else
          nil
        end
      end
    end
  end

  let :base_data_bag_item_content do
    {
      'rsyslog' => {
        'watched_logs' => {
          'nginx' => 'glob:/var/log/nginx/*.log'
        },
        'excluded_logs' => {
          'debug' => 'glob:/var/log/**/*-debug.log'
        }
      }
    }.tap do |h|
      h.stub(:raw_data) { h }
    end
  end

  let :env_data_bag_item_content do
    {
      'rsyslog' => {
        'server_search' => 'role:logstash'
      }
    }.tap do |h|
      h.stub(:raw_data) { h }
    end
  end

  %w(base_and_env bag_cascade).each do |loader_type|
    subject(:loader) { send(:"loader_from_#{loader_type}") }

    context "when loaded from #{loader_type.gsub(/_/, ' ')}" do
      it 'merges base config with env config' do
        loaded = loader.load_config['rsyslog']
        loaded['server_search'].should == 'role:logstash'
        loaded['watched_logs'].should_not be_empty
      end

      it 'rejects id, chef_type, and data_bag keys' do
        loaded = loader.load_config['rsyslog']
        %w(id chef_type data_bag).each do |key|
          loaded.should_not have_key(key)
        end
      end

      context 'when no configs are found' do
        let :run_context do
          double('run_context').tap do |ctx|
            ctx.stub(:log)
            ctx.stub(:data_bag_item).and_raise(Class.new(StandardError).new)
          end
        end

        it 'does not explode' do
          expect { loader.load_config }.to_not raise_error
        end
      end
    end
  end
end
