# Build the docker image
docker login --username=$DOCKER_USERNAME --password=$DOCKER_PASSWORD $DOCKER_REPO && docker build --cache-from $DOCKER_IMAGE -t $DOCKER_IMAGE . && docker push $DOCKER_IMAGE

# Release the Deployment
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
chmod +x ./kubectl && \
./kubectl patch deployment $DEPLOYMENT -n default -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"buildkite.build_id\":\"$BUILDKITE_BUILD_ID\"}}}}}"
