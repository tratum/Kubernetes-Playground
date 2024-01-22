# Start with a NixOS base image
FROM nixos/nix

# Environment variables
ARG KUBECTL_VERSION="v1.20.0"

USER root

# Install Kubectl
RUN nix-env -iA nixpkgs.kubectl

# Copy the Kubernetes cluster configuration scripts
COPY ./start-k8s-cluster.sh /start-k8s-cluster.sh
RUN chmod +x /start-k8s-cluster.sh

# Start the Kubernetes cluster when the container launches
CMD ["/start-k8s-cluster.sh"]
