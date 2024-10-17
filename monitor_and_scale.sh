#!/bin/bash

SERVICE_NAME="cloud_app_1"
MEMORY_LIMIT=134217728  # Memory limit in bytes (128 MiB)
MIN_REPLICAS=1          # Minimum number of replicas

# Check if the service exists
if ! docker ps --format '{{.Names}}' | grep -q "$SERVICE_NAME"; then
    echo "Error: Service '$SERVICE_NAME' not found."
    exit 1
fi

## Check the health status of the service
#HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$SERVICE_NAME" 2>/dev/null)
#
#if [ "$HEALTH_STATUS" != "healthy" ]; then
#    echo "Container $SERVICE_NAME is not healthy. Current status: $HEALTH_STATUS"
#    exit 1
#fi

# Get current memory usage
CURRENT_MEMORY=$(docker stats --no-stream --format "{{.MemUsage}}" "$SERVICE_NAME" | awk -F '/' '{print $1}' | sed 's/[^0-9]*//g')

if [[ -z "$CURRENT_MEMORY" ]]; then
    echo "Error: Could not retrieve memory usage for service '$SERVICE_NAME'. Is the service running?"
    exit 1
fi

# Convert current memory usage to bytes (assuming it is in MiB)
CURRENT_MEMORY_BYTES=$((CURRENT_MEMORY * 1024 * 1024))

echo "Current memory usage: $CURRENT_MEMORY_BYTES bytes"

# Check if memory limit is exceeded
if [ "$CURRENT_MEMORY_BYTES" -gt "$MEMORY_LIMIT" ]; then
    echo "Memory limit exceeded. Scaling up..."

    NEW_REPLICA_COUNT=$((CURRENT_MEMORY_BYTES / MEMORY_LIMIT + 1))
    echo "Scaling service '$SERVICE_NAME' to $NEW_REPLICA_COUNT replicas."

    # Scale the service
    if docker service scale "$SERVICE_NAME=$NEW_REPLICA_COUNT"; then
        echo "Successfully scaled service '$SERVICE_NAME' to $NEW_REPLICA_COUNT replicas."
    else
        echo "Error scaling service '$SERVICE_NAME'."
        exit 1
    fi
else
    # Scale down logic if memory usage is low
    CURRENT_REPLICAS=$(docker service inspect "$SERVICE_NAME" --format '{{.Spec.Mode.Replicated.Replicas}}')

    if [ "$CURRENT_REPLICAS" -gt "$MIN_REPLICAS" ]; then
        echo "Memory usage is within limits. Current replicas: $CURRENT_REPLICAS. Scaling down..."

        NEW_REPLICA_COUNT=$((CURRENT_REPLICAS - 1))
        echo "Scaling service '$SERVICE_NAME' down to $NEW_REPLICA_COUNT replicas."

        # Scale the service down
        if docker service scale "$SERVICE_NAME=$NEW_REPLICA_COUNT"; then
            echo "Successfully scaled service '$SERVICE_NAME' down to $NEW_REPLICA_COUNT replicas."
        else
            echo "Error scaling service '$SERVICE_NAME'."
            exit 1
        fi
    else
        echo "Memory usage is within limits. No scaling actions required."
    fi
fi
