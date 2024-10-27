. /etc/bash_completion

fix-kubectl-autocomp() {
  [[ $KUBECTL_AUTOCOMP_FIXED ]] || source <(curl -Ls http://bit.ly/kubectl-fix)
}

cd
common-env &> /dev/null

kubectl config set-context default --namespace=$NS
kubectl config use-context default

fix-kubectl-autocomp

alias motd='cat /etc/motd'
alias help='{ command help; motd; }'

## kubernetes
alias k='kubectl'

alias aliascomp='complete -F _complete_alias'
for a in k; do
  aliascomp $a
done

export PATH="${PATH}:${HOME}/.krew/bin"
touch .bash_history
export PROMPT_COMMAND="history -a; history -c; history -r; cp ~/.bash_history ~/public; $PROMPT_COMMAND"

export KUBEVAL_SCHEMA_LOCATION=https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master
export K8S_PROMPT=1

curl -sfLo /tmp/functions.sh http://presenter/functions.sh && . /tmp/functions.sh
motd