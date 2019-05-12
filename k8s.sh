if [ $BUILDKITE_BRANCH != "master" ]; then
  echo 'Not master... skipping'
  exit 0
else
  echo 'Is master... continue'
fi

YELLOW='\033[1;33m'

echo "${YELLOW}Version 18"

# Login to Docker
if [ -n "$GH_DOCKER_TOKEN" ]; then
  echo "${YELLOW}Using Docker Login: Github"
  echo $GH_DOCKER_TOKEN | docker login -u scottrobertson --password-stdin $DOCKER_REPO
else
  echo "${YELLOW}Using Docker Login: Google"
  export DOCKER_JSON_OUTPUT=$(echo -n "$DOCKER_JSON" | base64 -d)
  echo $DOCKER_JSON_OUTPUT | docker login -u _json_key --password-stdin $DOCKER_REPO
fi

# Build and push the Docker image
echo ''
echo "${YELLOW}Building: $DOCKER_IMAGE"
docker build --cache-from "$DOCKER_IMAGE:latest" -t "$DOCKER_IMAGE:latest" -t "$DOCKER_IMAGE:$BUILDKITE_COMMIT" .

echo ''
echo "${YELLOW}Pushing: $DOCKER_IMAGE:latest"
docker push "$DOCKER_IMAGE:latest"

echo ''
echo "${YELLOW}Pushing: $DOCKER_IMAGE:$BUILDKITE_COMMIT"
docker push "$DOCKER_IMAGE:$BUILDKITE_COMMIT"

# Install kubectl

echo ''
echo "${YELLOW}Installing kubectl"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl

# Lets tell k8s about the new image
echo ''
echo "${YELLOW}kubectl set image deployment/$DEPLOYMENT $DEPLOYMENT=$DOCKER_IMAGE:$BUILDKITE_COMMIT"
./kubectl set image -n default "deployment/$DEPLOYMENT" "$DEPLOYMENT"="$DOCKER_IMAGE:$BUILDKITE_COMMIT"

# Deploy 2 is useful for when we have web + sidekiq containers
if [ -n "$DEPLOYMENT_2" ]; then
  echo ''
  echo "${YELLOW}kubectl set image deployment/$DEPLOYMENT_2 $DEPLOYMENT_2=$DOCKER_IMAGE:$BUILDKITE_COMMIT"
  ./kubectl set image -n default "deployment/$DEPLOYMENT_2" "$DEPLOYMENT_2"="$DOCKER_IMAGE:$BUILDKITE_COMMIT"
fi

# Now lets wait for those deploys to finish
echo ''
echo "${YELLOW}Waiting for deploy: $DEPLOYMENT"
./kubectl rollout status deployment -w -n default $DEPLOYMENT

if [ -n "$DEPLOYMENT_2" ]; then
  echo ''
  echo "${YELLOW}Waiting for deploy: $DEPLOYMENT_2"
  ./kubectl rollout status deployment -w -n default $DEPLOYMENT_2
fi
