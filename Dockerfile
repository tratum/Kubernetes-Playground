ARG GITPOD_IMAGE=gitpod/workspace-base:latest
FROM ${GITPOD_IMAGE}

ARG KUBECTL_VERSION="v1.20.0"
ARG CRICTL_VERSION="v1.24.1"

USER root

## Install Kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && \
    mkdir -p /home/gitpod/.kube

## Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

## Install Kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash

## Install dependencies
RUN apt-get update && \
    apt-get install -y fzf conntrack


## Install crictl
RUN curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C /usr/local/bin -xz

# Install cri-dockerd
RUN git clone https://github.com/Mirantis/cri-dockerd.git && \
    cd cri-dockerd && \
    git checkout ${CRI_DOCKERD_VERSION} && \
    make && \
    make install
    
## Install easy ctx/ns switcher
RUN git clone https://github.com/blendle/kns.git && \
    cd kns/bin && \
    chmod +x kns && mv kns /usr/local/bin && \
    chmod +x ktx && mv ktx /usr/local/bin

## Install Krew
RUN set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    KREW="krew-${OS}_${ARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxvf "${KREW}.tar.gz" && \
    ./"${KREW}" install krew && \
    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> /home/gitpod/.bashrc

## Install Krew main plugins
RUN export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" && \
    kubectl krew install neat && \
    kubectl krew install access-matrix && \
    kubectl krew install advise-psp && \
    kubectl krew install cert-manager && \
    kubectl krew install ca-cert && \
    kubectl krew install get-all && \
    kubectl krew install ingress-nginx

# Add aliases
RUN echo 'alias k="kubectl"' >> /home/gitpod/.bashrc

## Install Minikube
RUN curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
    chmod +x minikube && \
    mv minikube /usr/local/bin/

## Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER gitpod
