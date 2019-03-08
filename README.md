## Kinaba BOSH Release

Use [elastic-stack-bosh-deployment](https://github.com/bosh-elastic-stack/elastic-stack-bosh-deployment) to deploy Elastic Stack.

### How to build this bosh release for development

#### Build and deploy this bosh release

```
bosh sync-blobs
bosh create-release --name=kibana --force --timestamp-version --tarball=/tmp/kibana-boshrelease.tgz && bosh upload-release /tmp/kibana-boshrelease.tgz
bosh -n -d kibana deploy manifest/kibana.yml --no-redact
```

#### How to test spec files

```
bundle install
bundle exec rspec spec/jobs/*_spec.rb
```