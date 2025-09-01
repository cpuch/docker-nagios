#!/usr/bin/env bash

# Export environment variables
if [[ -f .env ]]; then
    source .env
    export NAGIOS_VERSION="${NAGIOS_BRANCH#nagios-}"
    export GIT_COMMIT_SHORT=$(git rev-parse --short HEAD)
else
    echo "Error: .env file not found"
    exit 1
fi

# Ensure we're in the right directory
cd "$(dirname "$0")/.."

# Run build with bake
docker buildx bake --file docker-bake.hcl "$@"