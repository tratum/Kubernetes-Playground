FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

ARG INSTALL_KUBERNETES

# Install Kubernetes and Minikube
RUN if [ "$INSTALL_KUBERNETES" = "true" ]; then \
        curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
        chmod +x ./kubectl && \
        mv ./kubectl /usr/local/bin/kubectl && \
        curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
        chmod +x minikube && \
        mv minikube /usr/local/bin/ && \
        apt-get update && apt-get install -y conntrack && \
        minikube start --driver=none; \
    fi
