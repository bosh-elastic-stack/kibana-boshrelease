## Kinaba BOSH Release

Use [elastic-stack-bosh-deployment](https://github.com/bosh-elastic-stack/elastic-stack-bosh-deployment) to deploy Elastic Stack.

**ℹ️ Important ℹ️**

Since 0.11.0, kibana bosh release comes with [the pure Apache 2.0 licensed distribution](https://www.elastic.co/downloads/kibana-oss).
Please do not use previous versions.
If you want to use X-Pack features, download [Elastic License licensed distribution](https://www.elastic.co/jp/downloads/kibana) and build the bosh release with it by yourself. You can use [a prepared concourse task](#build-your-own-bosh-release-with-x-pack-by-concourse). 

### Build your own bosh release with X-Pack by Concourse

kibana boshrelease does not include X-Pack since it uses the pure Apache 2.0 licensed distribution.
You can use [create-el-bosh-release.yml](ci/create-el-bosh-release.yml) to build your own bosh release with Elastic License licensed distribution.

Here is a sample pipeline:

```yaml
resources:
- name: repo
  type: git
  source:
    uri: https://github.com/bosh-elastic-stack/kibana-boshrelease.git
- name: gh-release
  type: github-release
  source:
    user: bosh-elastic-stack
    repository: kibana-boshrelease
    access_token: ((github-access-token))
- name: release
  type: s3
  source:
    bucket: your-bucket
    regexp: kibana-boshrelease-(.*).tgz
    access_key_id: ((s3-access-key-id))
    secret_access_key: ((s3-secret-access-key))

jobs:
- name: create-el-bosh-release
  plan:
  - aggregate:
    - get: gh-release
      trigger: true
      params:
        include_source_tarball: true
    - get: repo
  - task: create-release
    params:
      VERSION_SUFFIX: "_el"
    file: repo/ci/create-el-bosh-release.yml
  - put: release
    params:
      file: bosh-releases/kibana-boshrelease-*.tgz
```

If you want to upload the release directly, use the following pipeline

```yaml
resources:
- name: repo
  type: git
  source:
    uri: https://github.com/bosh-elastic-stack/kibana-boshrelease.git
- name: gh-release
  type: github-release
  source:
    user: bosh-elastic-stack
    repository: kibana-boshrelease
    access_token: ((github-access-token))

jobs:
- name: create-el-bosh-release
  plan:
  - aggregate:
    - get: gh-release
      trigger: true
      params:
        include_source_tarball: true
    - get: repo
  - task: create-release
    params:
      VERSION_SUFFIX: "_el"
    file: repo/ci/create-el-bosh-release.yml
  - task: upload-release
    params:
      BOSH_CLIENT: ((bosh-client))
      BOSH_ENVIRONMENT: ((bosh-environment))
      BOSH_CLIENT_SECRET: ((bosh-client-secret))
      BOSH_CA_CERT: ((bosh-ca-cert))
    config:
      platform: linux
      image_resource:
        type: registry-image
        source:
          repository: bosh/main-bosh-docker
      inputs:
      - name: bosh-releases
      outputs:
      - name: bosh-releases
      run:
        path: bash
        args:
        - -c
        - |
          set -e
          bosh upload-release bosh-releases/*.tgz
```

![image](https://user-images.githubusercontent.com/106908/54046430-9ef44380-4217-11e9-8dfa-520fd8e044f7.png)


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
