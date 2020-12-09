FROM ubuntu:18.04

RUN apt-get -qq update; apt-get install -y \
  curl \
  git \
  jq \
  bash-completion \
  dnsutils \
  net-tools \
  unzip \
  tmux \
  vim
ENV KCTL_VERSION=v1.16.15
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KCTL_VERSION}/bin/linux/amd64/kubectl \
   && chmod +x ./kubectl \
   && mv ./kubectl /usr/local/bin/kubectl

RUN  curl -Ls https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash

RUN curl -Ls https://github.com/lalyos/gotty/releases/download/v2.0.0-alpha.4/gotty_2.0.0-alpha.4_linux_amd64.tar.gz \
  | tar -xz -C /usr/local/bin

RUN  curl -L https://github.com/zyedidia/micro/releases/download/v1.4.1/micro-1.4.1-linux64.tar.gz \
  | tar -xz -C /usr/local/bin/  --strip-components 1 micro-1.4.1/micro

RUN curl -LO https://github.com/simeji/jid/releases/download/0.7.2/jid_linux_amd64.zip \
  && unzip jid_linux_amd64.zip \
  && mv jid_linux_amd64 /usr/local/bin/jid

RUN kubectl completion bash > /etc/bash_completion.d/kubectl
RUN helm completion bash > /etc/bash_completion.d/helm
ADD https://raw.githubusercontent.com/cykerway/complete-alias/master/complete_alias  /etc/bash_completion.d/complete_alias
ADD motd /etc/motd
ADD https://gist.githubusercontent.com/lalyos/0d28f171b365fcea51f5345e97b43279/raw/mypropmt.sh /root/.prompt.sh
ADD bash_aliases /root/.bash_aliases