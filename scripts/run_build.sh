#!/usr/bin/env bash

# Export environment variables
if [ -f .env ]; then
    source .env
else
    echo "Using .env.example as fallback"
    source .env.example
fi

export NAGIOS_VERSION="${NAGIOS_BRANCH#nagios-}"
export GIT_COMMIT_SHORT=$(git rev-parse --short HEAD)

# Ensure we're in the right directory
cd "$(dirname "$0")/.."

# Run build with bake
docker buildx bake --file docker-bake.hcl "$@"