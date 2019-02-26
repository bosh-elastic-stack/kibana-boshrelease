require 'rspec'
require 'yaml'
require 'bosh/template/test'
require 'base64'

describe 'kibana job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job('kibana') }

  describe 'kibana.yml' do
    let(:template) { job.template('config/kibana.yml') }
    let(:links) { [
        Bosh::Template::Test::Link.new(
          name: 'elasticsearch',
          instances: [Bosh::Template::Test::LinkInstance.new(address: '10.0.8.2')],
          properties: {
            'elasticsearch'=> {
              'cluster_name' => 'test'
            },
          }
        )
      ] }

    it 'configures defaults successfully' do
      config = YAML.safe_load(template.render({}, consumes: links))
      expect(config['server.port']).to eq(5601)
      expect(config['server.host']).to eq('0.0.0.0')
      expect(config['kibana.index']).to eq('.kibana')
      expect(config['kibana.defaultAppId']).to eq('discover')
      expect(config['elasticsearch.hosts']).to eq(['http://10.0.8.2:9200'])
      expect(config['elasticsearch.requestTimeout']).to eq(300000)
      expect(config['elasticsearch.shardTimeout']).to eq(30000)
    end

    it 'makes a request to ES secure' do
      config = YAML.safe_load(template.render({'kibana' => {
        'elasticsearch' => {
          'protocol' => 'https',
          'port' => '443',
          'username' => 'admin',
          'password' => 'password',
        }
      }}, consumes: links))
      expect(config['elasticsearch.hosts']).to eq(['https://10.0.8.2:443'])
      expect(config['elasticsearch.customHeaders']['Authorization']).to eq('Basic YWRtaW46cGFzc3dvcmQ=')
      expect(config['elasticsearch.requestHeadersWhitelist']).to eq([])
    end

    it 'configures kibana.config_options' do
      config = YAML.safe_load(template.render({'kibana' => {
        'config_options' => {
            'xpack' => {
              'security' => {
                'enabled' => true
              }
          }
        }
      }}, consumes: links))
      expect(config['xpack']['security']['enabled']).to eq(true)
    end
    it 'multiple elasticsearch hosts' do
      config = YAML.safe_load(template.render({'kibana' => {
        'elasticsearch' => {
          'protocol' => 'https',
          'port' => '443'
        }
      }}, consumes: [
        Bosh::Template::Test::Link.new(
          name: 'elasticsearch',
          instances: [
            Bosh::Template::Test::LinkInstance.new(address: '10.0.8.1'),
            Bosh::Template::Test::LinkInstance.new(address: '10.0.8.2'),
            Bosh::Template::Test::LinkInstance.new(address: '10.0.8.3'),
            Bosh::Template::Test::LinkInstance.new(address: '10.0.8.4'),
            Bosh::Template::Test::LinkInstance.new(address: '10.0.8.5')
          ],
          properties: {
            'elasticsearch'=> {
              'cluster_name' => 'test'
            },
          }
        )
      ]))
      expect(config['elasticsearch.hosts']).to eq([
        'https://10.0.8.1:443',
        'https://10.0.8.2:443',
        'https://10.0.8.3:443',
        'https://10.0.8.4:443',
        'https://10.0.8.5:443'
      ])
    end
  end
end
