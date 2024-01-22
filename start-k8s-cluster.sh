#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Start k3s: Lightweight Kubernetes
# This will download and install k3s if it's not already installed
echo "Starting k3s Kubernetes Cluster..."
curl -sfL https://get.k3s.io | sh -

# Check if k3s is running
if systemctl is-active --quiet k3s; then
    echo "k3s Kubernetes Cluster is up and running."
else
    echo "Failed to start k3s Kubernetes Cluster."
    exit 1
fi

# Additional setup commands can go here
# For example, setting Kubernetes configurations, deploying applications, etc.

# Keep the script running to maintain the Kubernetes cluster
tail -f /dev/null
