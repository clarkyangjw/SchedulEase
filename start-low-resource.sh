#!/bin/bash
# Low-resource startup script for SchedulEase
# Optimized for VMs with limited resources (1GB RAM)

JAR_FILE="SchedulEase-0.0.1-SNAPSHOT.jar"

# Check if JAR file exists
if [ ! -f "$JAR_FILE" ]; then
    echo "Error: $JAR_FILE not found!"
    echo "Please make sure the JAR file is in the current directory."
    exit 1
fi

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Error: Java is not installed!"
    echo "Please install Java 17: sudo apt install -y openjdk-17-jdk"
    exit 1
fi

echo "Starting SchedulEase with low-resource configuration..."
echo "JVM Memory: -Xms256m -Xmx512m"
echo ""

# Database configuration via environment variables (optional)
# If these are set, they will override application.yml settings
# Example:
#   export SPRING_DATASOURCE_URL="jdbc:postgresql://YOUR_DB_IP:5432/schedulease"
#   export SPRING_DATASOURCE_USERNAME="postgres"
#   export SPRING_DATASOURCE_PASSWORD="your_password"

if [ -n "$SPRING_DATASOURCE_URL" ]; then
    echo "Using database URL from environment: $SPRING_DATASOURCE_URL"
fi

# Run with optimized JVM parameters for low-resource environments
java \
    -Xms256m \
    -Xmx512m \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UseStringDeduplication \
    -Djava.awt.headless=true \
    -jar "$JAR_FILE"

