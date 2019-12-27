# CI Scripts

Just for me

## Example Buildkite:

```yaml
env:
  DOCKER_IMAGE: "registry.digitalocean.com/scott/image"
  DOCKER_REPO: "https://registry.digitalocean.com"
  DOCKER_USERNAME: "DOCKER_USERNAME"
  DOCKER_PASSWORD: "DOCKER_PASSWORD"
  DEPLOYMENTS: "image-web,image-sidekiq"

steps:
  - command: "curl -L -s https://goo.gl/xvVHwM | bash"
```
