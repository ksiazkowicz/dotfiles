# vim:ft=zsh ts=2 sw=2 sts=2
CURRENT_FG='NONE'

zstyle ':zsh-kubectl-prompt:' separator ':'

# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  SEGMENT_SEPARATOR=$'\ue0b1'
}

# Begin a segment
prompt_segment() {
  local fg
  [[ -n $1 ]] && fg="%F{$1}" || fg="%f"
  [[ $CURRENT_FG != 'NONE' ]] && echo -n " %{$fg%F{$CURRENT_FG}%}$SEGMENT_SEPARATOR"
  echo -n "%{$fg%} "

  CURRENT_FG=$1
  [[ -n $2 ]] && echo -n $2
}

# End the prompt, closing any open segments
prompt_end() {
  [[ -n $CURRENT_FG ]] && echo -n " %{%k%F{$CURRENT_FG}%}$SEGMENT_SEPARATOR"
  echo -n "%{%f%}"
  CURRENT_FG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  local repo_info=$(git --no-optional-locks status --branch --porcelain=v2 2>&1 | awk -f $ZSH_CUSTOM/themes/chleb-git.gawk)
  [[ -z "$repo_info" ]] || prompt_segment 13 " $repo_info"
}

# Dir: current working directory
prompt_dir() {
  [[ -z "${PWD#?}" ]] || prompt_segment cyan "${${${PWD#?}/#${HOME#?}/~}:gs/\//  }"
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  [[ -n $VIRTUAL_ENV && -n $VIRTUAL_ENV_DISABLE_PROMPT ]] && prompt_segment 11 "🐍  $VIRTUAL_ENV:t"
}

prompt_status() {
  if [[ $RETVAL -ne 0 ]]; then
    prompt_segment 9 "✖ "
  else
    prompt_segment 10 "✔ "
  fi
}

# K8s context and namespace
prompt_k8s() {
  [[ -z "$ZSH_KUBECTL_PROMPT" ]] || prompt_segment 12 "⎈ $ZSH_KUBECTL_PROMPT"
}

prompt_awsvault() {
  [[ -z "$AWS_VAULT" ]] || prompt_segment 9 "🔐  $AWS_VAULT"
}

prompt_docker() {
  [[ -z $DOCKER_HOST || $DOCKER_HOST == tcp://localhost* ]] || prompt_segment 12 "🐋  ${DOCKER_MACHINE_NAME:-$DOCKER_HOST}"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_dir
  prompt_virtualenv
  prompt_k8s
  prompt_awsvault
  prompt_git
  prompt_docker
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
