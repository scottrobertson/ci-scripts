# CI Scripts

Just for me

## Example Buildkite:

```yaml
env:
  DOCKER_IMAGE: "eu.gcr.io/personal-stuff-193123/image"
  DOCKER_REPO: "https://eu.gcr.io"
  DOCKER_JSON: "base64jsonhere"

steps:
  - command: "export DEPLOYMENT=web && curl -L -s https://raw.githubusercontent.com/scottrobertson/ci-scripts/master/k8s.sh?t=$(date +%s) | bash"
    label: ":docker: Build and Deploy Web"

  - wait

  - command: "export DEPLOYMENT=sidekiq && curl -L -s https://raw.githubusercontent.com/scottrobertson/ci-scripts/master/k8s.sh?t=$(date +%s) | bash"
    label: ":docker: Build and Deploy Sidekiq"
```
