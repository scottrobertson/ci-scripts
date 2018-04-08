#!/bin/bash

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
chmod +x ./kubectl && \
./kubectl patch deployment $1 -n default -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"buildkite.build_id\":\"$BUILDKITE_BUILD_ID\"}}}}}"
