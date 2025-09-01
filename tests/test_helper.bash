# BATS test configuration and shared functions
# This file is loaded by all test files

# Set test timeout (in seconds)
export BATS_TEST_TIMEOUT=300

# Container configuration - shared across all tests
export CONTAINER_NAME=${CONTAINER_NAME:-nagios-test}
export IMAGE_NAME=${IMAGE_NAME:-cpuchalver/nagios}

# Colors for output
export RED="\033[1;31m"
export GREEN="\033[1;32m"
export YELLOW="\033[1;33m"
export BLUE="\033[1;34m"
export NC="\033[0m" # No Color

# Load environment variables
if [ -f '.env' ]; then
    source .env
fi

# Load BATS libraries if available
if [ -f '/usr/lib/bats-support/load.bash' ]; then
    load '/usr/lib/bats-support/load'
fi
if [ -f '/usr/lib/bats-assert/load.bash' ]; then
    load '/usr/lib/bats-assert/load'
fi

# Shared setup and teardown functions
# setup_file() {
    
#     # Build docker image
#     echo -e "${YELLOW}Building docker image...${NC}" >&3
#     docker build -f Dockerfile -t "${IMAGE_NAME}" .
    
#     # Start container
#     echo -e "${YELLOW}Starting docker container...${NC}" >&3
#     docker run --rm --name "${CONTAINER_NAME}" -d "${IMAGE_NAME}" >/dev/null 2>&1
    
#     # Wait for services to start
#     echo -e "${YELLOW}Waiting for container readiness...${NC}" >&3
#     sleep 5

#     # Run tests
#     echo -e "${YELLOW}Running test...${NC}" >&3
#     echo >&3
# }

# teardown_file() {
#     # Stop and remove container
#     docker stop "${CONTAINER_NAME}" >/dev/null 2>&1 || true
#     docker rm "${CONTAINER_NAME}" >/dev/null 2>&1 || true
# }

# Function to check if container exists and is running
container_is_running() {
    docker ps --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"
}

# Function to wait for container to be ready
wait_for_container() {
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if container_is_running; then
            # Test if we can execute commands
            if docker exec "${CONTAINER_NAME}" echo "test" > /dev/null 2>&1; then
                return 0
            fi
        fi
        
        echo "# Waiting for container... attempt $attempt/$max_attempts" >&3
        sleep 2
        ((attempt++))
    done
    
    echo "# Container failed to become ready after $max_attempts attempts" >&3
    return 1
}

# Helper function to run commands in container
run_in_container() {
    docker exec "${CONTAINER_NAME}" "$@"
}
