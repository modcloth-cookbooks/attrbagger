describe 'attrbagger::default' do
  let :chef_run do
    Chef::Config[:attrbagger] = {:autoload => true}
    ChefSpec::ChefRunner.new(log_level: ENV['DEBUG'] ? :debug : :error) do |node|
      node.normal['flurb']['foop']['buzz'] = 2
      node.normal['attrbagger']['configs']['flurb::foop'] = [
        'data_bag_item[derps::ham]', 'data_bag_item[noodles::foop]'
      ]
      node.normal['attrbagger']['configs']['bork'] = ['data_bag_item[ack]']
    end
  end

  let(:updated_buzz) { rand(100..199) }

  let :data_bags do
    {
      'derps' => {
        'ham' => {
          'buzz' => 9,
          'nerf' => true
        }
      },
      'noodles' => {
        'foop' => {
          'buzz' => updated_buzz
        }
      }
    }
  end

  let(:client) do
    cl = chef_run.instance_variable_get(:@client)
    cl.instance_variable_set(:@run_context, chef_run.run_context)
    run_status = Chef::RunStatus.new(chef_run.node, cl.events)
    run_status.run_context = cl.setup_run_context
    cl.instance_variable_set(:@run_status, run_status)
    cl
  end

  before do
    Attrbagger.any_instance.stub(:data_bag_item) do |bag, item|
      (data_bags[bag] || {})[item]
    end
  end

  xit 'merges attributes into the node based on bag configs' do
    client.run_started
    chef_run.converge('attrbagger::default')
    chef_run.node['flurb']['foop']['buzz'].should == updated_buzz
    chef_run.node['flurb']['foop']['nerf'].should be_true
  end

  xit 'ignores malformed data bag specifications' do
    client.run_started
    chef_run.converge('attrbagger::default')
    chef_run.node['bork'].should be_nil
  end
end
