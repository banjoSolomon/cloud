#!/bin/bash

# Enable error handling
set -e

# Name of your Docker service (from docker-compose)
SERVICE_NAME="app"
MEMORY_LIMIT_MB=128  # Memory limit in MB
SCALE_UP_THRESHOLD=123  # Threshold to trigger scaling up in MB
SCALE_DOWN_THRESHOLD=100  # Threshold to trigger scaling down in MB
MAX_REPLICAS=5  # Maximum replicas
MIN_REPLICAS=1  # Minimum replicas

# Set higher COMPOSE_HTTP_TIMEOUT to avoid timeouts
export COMPOSE_HTTP_TIMEOUT=300

# Change to the directory containing the docker-compose file
cd "$(dirname "$0")" || exit 1

# Variable to track scaling status
scaling_in_progress=false

# Function to get current memory usage of the container
get_memory_usage() {
  docker stats --no-stream --format "{{.MemUsage}}" $(docker-compose ps -q $SERVICE_NAME) | awk -F '[ /]+' '{gsub(/[a-zA-Z]/, "", $1); print $1}' | tr -d '\n'
}

# Function to get the current number of replicas
get_current_scale() {
  docker-compose ps -q $SERVICE_NAME | wc -l
}

# Check if a container exists
container_exists() {
  docker ps -a --format "{{.ID}}" | grep -q "$1"
}

# Function to scale the service up
scale_service() {
  current_scale=$(get_current_scale)
  new_scale=$((current_scale + 1))

  # Only scale up if not at max replicas
  if [ "$current_scale" -lt "$MAX_REPLICAS" ]; then
    echo "[$(date)] Scaling service $SERVICE_NAME to $new_scale replicas"
    if ! docker-compose up --scale "$SERVICE_NAME=$new_scale" -d; then
      echo "[$(date)] Failed to scale service $SERVICE_NAME to $new_scale replicas"
    else
      scaling_in_progress=true
    fi
  else
    echo "[$(date)] Max replicas reached ($MAX_REPLICAS). Cannot scale further."
  fi
}

# Function to scale the service down
scale_down_service() {
  current_scale=$(get_current_scale)
  new_scale=$((current_scale - 1))

  # Only scale down if above min replicas
  if [ "$current_scale" -gt "$MIN_REPLICAS" ]; then
    echo "[$(date)] Scaling service $SERVICE_NAME down to $new_scale replicas"
    if docker-compose up --scale "$SERVICE_NAME=$new_scale" -d; then
      # Ensure containers exist before removal
      container_id=$(docker-compose ps -q $SERVICE_NAME | tail -n 1)
      if container_exists "$container_id"; then
        docker rm -f "$container_id"
      else
        echo "[$(date)] Container $container_id does not exist, skipping removal."
      fi
    else
      echo "[$(date)] Failed to scale service $SERVICE_NAME down to $new_scale replicas"
    fi
  else
    echo "[$(date)] Only one replica running. Cannot scale down further."
  fi
}

# Function to send concurrent requests (for load testing)
send_requests() {
  URL="http://localhost:8080/fibonacci/90000"  # Replace with your endpoint
  COUNT=90000  # Number of requests to send

  echo "[$(date)] Sending $COUNT concurrent requests to $URL..."

  for i in $(seq 1 $COUNT); do
    curl -s "$URL" &
  done

  wait  # Wait for all background requests to complete
  echo "[$(date)] All requests sent."
}

# Trap signal for graceful shutdown
trap "echo 'Stopping script...'; exit" SIGINT SIGTERM

# Monitor loop to auto-scale the service based on memory usage
while true; do
  # Get current memory usage in MB
  memory_usage=$(get_memory_usage | sed 's/[^0-9.]//g' | awk '{print int($1)}')

  # Validate memory usage
  if [[ ! "$memory_usage" =~ ^[0-9]+$ ]]; then
    echo "[$(date)] Invalid memory usage: $memory_usage. Skipping this check."
    continue
  fi

  # Get current replica count
  current_scale=$(get_current_scale)

  echo "[$(date)] Current memory usage: $memory_usage MB. Current replicas: $current_scale"

  # Check if memory usage exceeds the threshold for scaling up
  if [ "$memory_usage" -ge "$SCALE_UP_THRESHOLD" ] && [ "$scaling_in_progress" = false ]; then
    echo "[$(date)] Memory usage ($memory_usage MB) exceeded threshold ($SCALE_UP_THRESHOLD MB). Scaling service..."
    scale_service

  # Check if memory usage is below the threshold for scaling down
  elif [ "$memory_usage" -lt "$SCALE_DOWN_THRESHOLD" ] && [ "$current_scale" -gt "$MIN_REPLICAS" ]; then
    echo "[$(date)] Memory usage ($memory_usage MB) is below threshold for scaling down. Scaling down service..."
    scale_down_service

  else
    echo "[$(date)] Memory usage is under control ($memory_usage MB)."
  fi

  # Sleep for a brief period after scaling to allow the service to stabilize
  if [ "$scaling_in_progress" = true ]; then
    echo "[$(date)] Waiting for the service to stabilize after scaling..."
    sleep 60  # Adjust this duration as needed for service stabilization
    scaling_in_progress=false
  else
    # Sleep for 30 seconds before the next memory usage check
    sleep 30
  fi
done
