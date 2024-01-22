# Start with a standard Linux base image
FROM ubuntu:latest

# Install Nix
RUN apt-get update && \
    apt-get install -y curl xz-utils && \
    curl -L https://nixos.org/nix/install | sh

# Environment variables
ARG KUBECTL_VERSION="v1.20.0"

# Load Nix commands into the current shell session
RUN . /root/.nix-profile/etc/profile.d/nix.sh

# Install Kubectl using Nix
RUN nix-env -iA nixpkgs.kubectl

# Create the Gitpod user and group
RUN groupadd -r gitpod && \
    useradd -r -g gitpod -d /home/gitpod -m -s /bin/bash gitpod

# Copy the Kubernetes cluster configuration scripts
COPY ./start-k8s-cluster.sh /start-k8s-cluster.sh
RUN chmod +x /start-k8s-cluster.sh

# Switch to the Gitpod user
USER gitpod

# Start the Kubernetes cluster when the container launches
CMD ["/start-k8s-cluster.sh"]
