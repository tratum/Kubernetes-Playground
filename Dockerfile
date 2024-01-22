# Start with a NixOS base image
FROM nixos/nix

# Set environment variables
ARG KUBECTL_VERSION="v1.20.0"

USER root

# Install Kubectl using Nix
RUN nix-env -iA nixpkgs.kubectl

# Create the Gitpod user and group
RUN addgroup --system gitpod && \
    adduser --disabled-password --gecos '' --system --ingroup gitpod gitpod

# Copy the Kubernetes cluster configuration scripts
COPY ./start-k8s-cluster.sh /start-k8s-cluster.sh
RUN chmod +x /start-k8s-cluster.sh

# Start the Kubernetes cluster when the container launches
CMD ["/start-k8s-cluster.sh"]

# Switch to the Gitpod user
USER gitpod
