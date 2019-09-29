# vim:ft=zsh ts=2 sw=2 sts=2
CURRENT_FG='NONE'

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
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    prompt_segment 13

    setopt promptsubst
    autoload -Uz vcs_info

    local STATUS=''

    # is branch ahead?
    if $(echo "$(git log origin/$(git_current_branch)..HEAD 2> /dev/null)" | grep '^commit' &> /dev/null); then
      STATUS="$STATUS↑"
    fi

    # is branch behind?
    if $(echo "$(git log HEAD..origin/$(git_current_branch) 2> /dev/null)" | grep '^commit' &> /dev/null); then
      STATUS="$STATUS↓"
    fi

    [[ -z $STATUS ]] && STATUS='≡'

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' unstagedstr '● '
    zstyle ':vcs_info:*' formats '%u%b'
    zstyle ':vcs_info:*' actionformats '%u%b (%a)'
    vcs_info
    echo -n "$PL_BRANCH_CHAR ${vcs_info_msg_0_%%} $STATUS"
  fi
}

# Dir: current working directory
prompt_dir() {
  local CWD="${PWD#?}"
  [[ -z "$CWD" ]] && return

  local SHORT_HOME="${HOME#?}"
  CWD="${CWD/#$SHORT_HOME/~}"
  CWD="$CWD:gs/\//  "
  prompt_segment cyan $CWD
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment 11 `basename $virtualenv_path`
  fi
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
  (( $+commands[kubectl] )) || return
  K8S_CONTEXT=`kubectl config current-context` 2> /dev/null
  K8S_NAMESPACE=`kubectl config view --minify --output 'jsonpath={..namespace}'` 2> /dev/null
  [[ -z "$K8S_CONTEXT" ]] && return
  prompt_segment 12 "⎈ $K8S_CONTEXT:${K8S_NAMESPACE:-default}"
}

prompt_awsvault() {
  [[ -z "$AWS_VAULT" ]] || prompt_segment 9 "🔐  $AWS_VAULT"
}

prompt_docker() {
  local DOCKER_MACHINE=${DOCKER_MACHINE_NAME:-$DOCKER_HOST}
  [[ -z $DOCKER_HOST || $DOCKER_HOST == tcp://localhost* ]] && return
  prompt_segment 12 "$DOCKER_MACHINE"
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
