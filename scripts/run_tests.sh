#!/usr/bin/env bash

# Export env variables
if [ -f .env ]; then
    source .env
else
    source .env.example
fi

export NAGIOS_VERSION="${NAGIOS_BRANCH#nagios-}"

# Docker image
IMAGE_CONTAINER="cpuchalver/nagios:${NAGIOS_VERSION}"

# Test files in order of execution
TEST_FILES=(
    "setup.bats"
    "config.bats"
    "services.bats"
    "web.bats"
    "monitoring.bats"
    "tools.bats"
)

# Check if BATS is installed
if ! command -v bats &> /dev/null; then
    echo "BATS is not installed. Please install it first:"
    echo "sudo apt install bats bats-assert bats-support"
    exit 1
fi

# Ensure we're in the right directory
cd "$(dirname "$0")/.."

# Build image
scripts/run_build.sh

# Clean up test containers
docker stop nagios-test &> /dev/null || true

# Start test container
docker run --rm --name nagios-test -d "${IMAGE_CONTAINER}" 2>&1 > /dev/null

# Function to run a test file
run_test_file() {
    local test_file="$1"
    local test_path="tests/${test_file}"
    
    bats "$test_path"
}

# Run setup first (this builds and starts the container)
if ! run_test_file "setup.bats"; then
    echo "Setup failed! Cannot continue with tests."
    exit 1
fi

# Run all other tests
for test_file in "${TEST_FILES[@]:1}"; do  # Skip setup.bats as it's already run
    if [ -f "tests/$test_file" ]; then
        run_test_file "$test_file"
    fi
done

# Stop test containers
docker stop nagios-test &> /dev/null || true