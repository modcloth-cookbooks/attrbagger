describe 'attrbagger::default' do
  let :chef_run do
    ChefSpec::ChefRunner.new do |node|
      node.set['flurb'] = {'foop' => {'bones' => 2}}
      node.set['attrbagger']['configs']['flurb::foop'] = [
        'data_bag[derps::ham]', 'data_bag[noodles::foop]'
      ]
      node.set['attrbagger']['configs']['bork'] = ['data_bag[ack]']
    end
  end

  let(:updated_bones) { rand(100..199) }

  let :data_bags do
    {
      'derps' => {
        'ham' => {
          'bones' => 9
        }
      },
      'noodles' => {
        'foop' => {
          'bones' => updated_bones
        }
      }
    }
  end

  before do
    Attrbagger.any_instance.stub(:data_bag_item) do |bag, item|
      (data_bags[bag] || {})[item]
    end
  end

  it 'autoloads configs specified in attrbagger.configs' do
    chef_run.converge('attrbagger::default')
    chef_run.node['flurb']['foop']['bones'].should == updated_bones
  end
end
