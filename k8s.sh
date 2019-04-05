if [ $BUILDKITE_BRANCH != "master" ]; then
  echo 'Not master... skipping'
  exit 0
else
  echo 'Is master... continue'
fi

echo 'Version 6'

printenv

# Login to Docker
export DOCKER_JSON_OUTPUT=$(echo -n "$DOCKER_JSON" | base64 -d)
echo $DOCKER_JSON_OUTPUT | docker login -u _json_key --password-stdin $DOCKER_REPO

# Build the image
docker build --cache-from $DOCKER_IMAGE -t $DOCKER_IMAGE . || exit 1
docker push $DOCKER_IMAGE || exit 1
docker tag "$DOCKER_IMAGE:latest" "$DOCKER_IMAGE:$BUILDKITE_COMMIT" && docker push "$DOCKER_IMAGE:$BUILDKITE_COMMIT" || exit 1

# Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl

# Deploy the new imahe by changing the annotation on the deployment. This will trigger k8s to redeploy and pull the latest image

echo "Deploying $DEPLOYMENT"
kubectl set image "deployment/$DEPLOYMENT" "$DEPLOYMENT=$DOCKER_IMAGE:$BUILDKITE_COMMIT"

if [ -n "$DEPLOYMENT_2" ]; then
  echo "Deploying $DEPLOYMENT_2"
  kubectl set image "deployment/$DEPLOYMENT_2" "$DEPLOYMENT_2=$DOCKER_IMAGE:$BUILDKITE_COMMIT"
fi

# Now lets wait for those deploys to finish

echo "Waiting for deploy: $DEPLOYMENT"
./kubectl rollout status deployment -w -n default $DEPLOYMENT

if [ -n "$DEPLOYMENT_2" ]; then
  echo "Waiting for deploy: $DEPLOYMENT_2"
  ./kubectl rollout status deployment -w -n default $DEPLOYMENT_2
fi
