if [ "$BUILDKITE_BRANCH" = "master" ]; then
  echo 'Is master... continue'
else
  echo 'Not master... skipping'
  exit 0
fi

VERSION="6"

YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Version ${VERSION}${NC}"

# Login to Docker
if [ -n "$GH_DOCKER_TOKEN" ]; then
  echo -e "${YELLOW}Using Docker Login: Github${NC}"
  echo $GH_DOCKER_TOKEN | docker login -u scottrobertson --password-stdin $DOCKER_REPO
fi

if [ -n "$DOCKER_JSON" ]; then
  echo -e "${YELLOW}Using Docker Login: Google${NC}"
  export DOCKER_JSON_OUTPUT=$(echo -n "$DOCKER_JSON" | base64 -d)
  echo $DOCKER_JSON_OUTPUT | docker login -u _json_key --password-stdin $DOCKER_REPO
fi

if [ -n "$DOCKER_USERNAME" ]; then
  echo -e "${YELLOW}Using Docker Login: Normal${NC}"
  echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin $DOCKER_REPO
fi

# Build and push the Docker image
echo ''
echo -e "${YELLOW}Building: $DOCKER_IMAGE${NC}"
docker build --cache-from "$DOCKER_IMAGE:latest" -t "$DOCKER_IMAGE:latest" -t "$DOCKER_IMAGE:$BUILDKITE_COMMIT" .

echo ''
echo -e "${YELLOW}Pushing: $DOCKER_IMAGE:latest${NC}"
docker push "$DOCKER_IMAGE:latest" || exit 1

echo ''
echo -e "${YELLOW}Pushing: $DOCKER_IMAGE:$BUILDKITE_COMMIT${NC}"
docker push "$DOCKER_IMAGE:$BUILDKITE_COMMIT" || exit 1

# Install kubectl
echo ''
echo -e "${YELLOW}Installing kubectl${NC}"
curl -LOs https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl
echo '...done'

DEPLOYMENTS_ARRAY=$(echo $DEPLOYMENTS | tr "," "\n")

echo ''
echo "Running Deployments: $DEPLOYMENTS"
echo ''

# Lets tell k8s about the new image
for deploy in $DEPLOYMENTS_ARRAY
do
  echo ''
  echo -e "${YELLOW}Deploy: $deploy${NC}"
  ./kubectl set image -n default "deployment/$deploy" "*"="$DOCKER_IMAGE:$BUILDKITE_COMMIT" || exit 1
  echo '...done'
done

# Now lets wait for those deploys to finish
for deploy in $DEPLOYMENTS_ARRAY
do
  echo ''
  echo -e "${YELLOW}Waiting for deploy: $deploy${NC}"
  ./kubectl rollout status deployment -w -n default $deploy || exit 1
done


echo ''
echo 'all done'
