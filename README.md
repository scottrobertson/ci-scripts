# CI Scripts

Just for me

## Example Buildkite:

```yaml
env:
  DOCKER_IMAGE: "eu.gcr.io/personal-stuff-193123/IMAGENAME"
  DOCKER_REPO: "https://eu.gcr.io"
  DOCKER_JSON: "here"

steps:
  - command: "export DEPLOYMENT=web && curl -v -L -s \"https://goo.gl/xvVHwM?t=$(date +%s)\" | bash"
    label: ":docker: Build and Deploy Web"

  - wait

  - command: "export DEPLOYMENT=sidekiq && curl -v -L -s \"https://goo.gl/xvVHwM?t=$(date +%s)\" | bash"
    label: ":docker: Build and Deploy Sidekiq"
```
