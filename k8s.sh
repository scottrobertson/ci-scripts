printenv

# Login to Docker
export DOCKER_JSON_OUTPUT=$(echo -n "$DOCKER_JSON" | base64 -d)
echo $DOCKER_JSON_OUTPUT | docker login -u _json_key --password-stdin $DOCKER_REPO

# Build the image
docker build --cache-from $DOCKER_IMAGE -t $DOCKER_IMAGE . || exit 1
docker push $DOCKER_IMAGE || exit 1

# Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl

# Deploy
./kubectl patch deployment $DEPLOYMENT -n default -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"buildkite.build_id\":\"$BUILDKITE_BUILD_ID\"}}}}}"

# Wait on the Deployment
./kubectl rollout status deployment -w -n default $DEPLOYMENT
