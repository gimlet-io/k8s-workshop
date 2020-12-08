#!/usr/bin/env bash

# kubectl expose deployment user0 --target-port=2015 --port 80 --name presenter
install-bashrc() {
  ## !!! NOTE: this should be run in workshop namespace
  ## appned this single line to the end of ~/.bashrc :
  ## echo 'curl -sLo /tmp/functions.sh http://presenter/functions.sh && . /tmp/functions.sh
  for d in $(kubectl get deployment -o name -l user) ; do
    echo "---> $d"
    kubectl exec $d -it -- bash -xc "echo 'curl -sLo /tmp/functions.sh http://presenter/functions.sh && . /tmp/functions.sh' >> /root/.bashrc"
  done
}

ucs() {
 curl -s http://presenter/.bash_history | tail -${1:-1}
}
debug() {
    if ((DEBUG)); then
       echo "===> [${FUNCNAME[1]}] $*" 1>&2
    fi
}
save-functions() {
    declare desc="saves all bash function into a file"
    : ${WEBDAVURL:=presenter}

    debug $desc
    declare -f > ${FUNCTIONS:=$HOME/functions.sh}

    echo download it from http://${WEBDAVURL}/functions.sh
}

main() {
  # if last arg is -d sets DEBUG
  [[ ${@:$#} =~ -d ]] && { set -- "${@:1:$(($#-1))}" ; DEBUG=1 ; } || :

  if [[ $1 =~ :: ]]; then
    debug DIRECT-COMMAND  ...
    command=${1#::}
    shift
    $command "$@"
  else
    debug default-command
    save-functions
  fi
}

nodeports ()
{
    echo "===> NodePort services:";
    kubectl get svc -o jsonpath="{range .items[?(.spec.type == 'NodePort')]} {.metadata.name} -> http://n1.k8z.eu:{.spec.ports[0].nodePort} {'\n'}{end}";
    echo
}

install-envsubst() {
  type envsubst &> /dev/null || apt-get install -y gettext-base
}

diffp() {
  declare desc="diff local file with presenter version"
  declare file=${1}
  : ${file:? required}
  shift
  : ${WEBDAVURL:=presenter}

  fullpath=$(readlink -f $file)
  url=http://${WEBDAVURL}${fullpath#$HOME}

  diff $@ $file <(curl -s http://${WEBDAVURL}${fullpath#$HOME})

}

distribute-file() {
    declare desc="distributes a local file via webdav"
    declare file=${1}
    : ${WEBDAVURL:=presenter}

    : ${file:? required}
    debug ${desc} : ${file}

    fullpath=$(readlink -f $file)
    url=http://${WEBDAVURL}${fullpath#$HOME}
    debug $url

    cat > $HOME/eval <<EOF
    type envsubst &> /dev/null || apt-get install -y gettext-base
    curl -s $url | envsubst | kubectl apply -f -
EOF
}
install-bat() {
  curl -sL https://github.com/sharkdp/bat/releases/download/v0.17.1/bat-v0.17.1-x86_64-unknown-linux-gnu.tar.gz | tar -xz --strip-components=1  -C /usr/local/bin  bat-v0.17.1-x86_64-unknown-linux-gnu/bat
}

install-krew() {
  [[ -e  ~/.krew/bin/ ]] || (
  set -x; cd "$(mktemp -d)" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')" &&
  "$KREW" install krew
  )
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
}

krew-examples() {
  kubectl krew index add cs https://github.com/ContainerSolutions/kubernetes-examples.git
  kubectl krew install cs/examples
}

install-kubectx() {
  [[ -e  /usr/local/bin/fzf ]] || curl -L https://github.com/junegunn/fzf/releases/download/0.24.3/fzf-0.24.3-linux_amd64.tar.gz|tar -xz -C /usr/local/bin/

  [[ -e /usr/local/bin/kubectx  ]] ||  (
      curl -L -o /usr/local/bin/kubectx https://github.com/ahmetb/kubectx/releases/download/v0.9.1/kubectx
      chmod +x /usr/local/bin/kubectx
  )

}

zz() {
    history -p '!!' > $HOME/eval;
    cat $HOME/eval
}

lazy() {
  declare desc="downloads a file from master session, and evals it"

  curl -s http://presenter/eval | BASH_ENV=<(echo alias k=kubectl) bash -O expand_aliases -x
}

load-functions() {
    curl -sLo /tmp/functions.sh http://presenter/functions.sh
    . /tmp/functions.sh
    echo "---> functions loaded ..." 1>&2
}

echo "---> $BASH_SOURCE reloaded ..." 1>&2

alias r=". $HOME/hack.sh"
alias rr=". $HOME/hack.sh; save-functions"

[[ "$0" == "$BASH_SOURCE" ]] && main "$@" || true