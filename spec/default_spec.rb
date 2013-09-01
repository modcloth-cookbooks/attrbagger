describe 'attrbagger::default' do
  let :chef_run do
    ChefSpec::ChefRunner.new do |node|
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

  before do
    Attrbagger.any_instance.stub(:data_bag_item) do |bag, item|
      (data_bags[bag] || {})[item]
    end
  end

  it 'merges attributes into the node based on bag configs' do
    chef_run.converge('attrbagger::default')
    chef_run.node['flurb']['foop']['buzz'].should == updated_buzz
    chef_run.node['flurb']['foop']['nerf'].should be_true
  end

  it 'ignores malformed data bag specifications' do
    chef_run.converge('attrbagger::default')
    chef_run.node['bork'].should be_nil
  end
end
