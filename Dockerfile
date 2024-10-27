FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update; apt-get install -y \
  curl \
  git \
  jq \
  bash-completion \
  dnsutils \
  net-tools \
  unzip \
  tmux \
  vim \
  gettext-base

ENV KCTL_VERSION=v1.16.15
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KCTL_VERSION}/bin/linux/amd64/kubectl \
   && chmod +x ./kubectl \
   && mv ./kubectl /usr/local/bin/kubectl

RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

RUN curl -Ls https://github.com/lalyos/gotty/releases/download/v2.0.0-alpha.4/gotty_2.0.0-alpha.4_linux_amd64.tar.gz \
  | tar -xz -C /usr/local/bin

RUN curl -sL https://github.com/sharkdp/bat/releases/download/v0.17.1/bat-v0.17.1-x86_64-unknown-linux-gnu.tar.gz | tar -xz --strip-components=1  -C /usr/local/bin  bat-v0.17.1-x86_64-unknown-linux-gnu/bat

RUN cd "$(mktemp -d)" \
    && KREW="krew-linux_amd64" \
    && curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" \
    && tar zxvf "${KREW}.tar.gz" \
    && ./"${KREW}" install krew
RUN curl -L https://github.com/junegunn/fzf/releases/download/0.24.3/fzf-0.24.3-linux_amd64.tar.gz|tar -xz -C /usr/local/bin/

RUN kubectl completion bash > /etc/bash_completion.d/kubectl
RUN helm completion bash > /etc/bash_completion.d/helm
ADD https://raw.githubusercontent.com/cykerway/complete-alias/master/complete_alias  /etc/bash_completion.d/complete_alias
ADD motd /etc/motd
ADD bash_aliases /root/.bash_aliases

CMD gotty -w bash
