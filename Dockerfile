# Start with a standard Linux base image
FROM ubuntu:latest

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y curl xz-utils sudo

# Create a non-root user for the Nix installation
RUN useradd -m -s /bin/bash nixuser && \
    echo "nixuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/nixuser && \
    chmod 0440 /etc/sudoers.d/nixuser

USER nixuser
WORKDIR /home/nixuser

# Install Nix as non-root user
RUN curl -L https://nixos.org/nix/install | sh && \
    . /home/nixuser/.nix-profile/etc/profile.d/nix.sh

# Switch back to root user to perform further actions
USER root

# Environment variables
ARG KUBECTL_VERSION="v1.20.0"

# Install Kubectl using Nix
RUN . /home/nixuser/.nix-profile/etc/profile.d/nix.sh && \
    nix-env -iA nixpkgs.kubectl

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
