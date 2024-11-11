#!/bin/bash

if [[ -z "$JAVA_HOME" ]]; then
  echo "Error: JAVA_HOME is not set. Please set it to your Java installation path."
  exit 1
fi

PROJECT_DIR=$(pwd)
TARGET_DIR="$PROJECT_DIR/target"
JAR_NAME="demo-0.0.1-SNAPSHOT.jar"
echo "Cleaning previous builds..."
mvn clean

echo "Running unit tests..."
mvn -B clean verify
if [[ $? -ne 0 ]]; then
  echo "Error: Some tests failed. Aborting build."
  exit 1
fi

echo "Building and packaging the application..."
mvn package

if [[ ! -f "$TARGET_DIR/$JAR_NAME" ]]; then
  echo "Error: Build failed. JAR file not found in target directory."
  exit 1
fi

echo "Running the application..."
java -jar "$TARGET_DIR/$JAR_NAME"
