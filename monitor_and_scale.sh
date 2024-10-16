#!/bin/bash

SERVICE_NAME="cloud_app_1"
MEMORY_LIMIT=134217728

if ! docker ps --format '{{.Names}}' | grep -q "$SERVICE_NAME"; then
    echo "Error: Service '$SERVICE_NAME' not found."
    exit 1
fi

HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' $SERVICE_NAME 2>/dev/null)

if [ "$HEALTH_STATUS" != "healthy" ]; then
    echo "Container $SERVICE_NAME is not healthy. Current status: $HEALTH_STATUS"
    exit 1
fi

CURRENT_MEMORY=$(docker stats --no-stream --format "{{.MemUsage}}" $SERVICE_NAME | awk -F '/' '{print $1}' | sed 's/[^0-9]*//g')

if [[ -z "$CURRENT_MEMORY" ]]; then
    echo "Error: Could not retrieve memory usage for service '$SERVICE_NAME'. Is the service running?"
    exit 1
fi

CURRENT_MEMORY_BYTES=$((CURRENT_MEMORY * 1024))
if [ "$CURRENT_MEMORY_BYTES" -gt "$MEMORY_LIMIT" ]; then
    echo "Memory limit exceeded. Scaling up..."

    NEW_REPLICA_COUNT=$((CURRENT_MEMORY_BYTES / MEMORY_LIMIT + 1))
    echo "Scaling service '$SERVICE_NAME' to $NEW_REPLICA_COUNT replicas."
    docker service scale app=$NEW_REPLICA_COUNT
else
    echo "Memory usage is within limits."
fi
