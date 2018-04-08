docker login --username=$DOCKER_USERNAME --password=$DOCKER_PASSWORD $DOCKER_REPO && docker build --cache-from $1 -t $1 . && docker push $1
