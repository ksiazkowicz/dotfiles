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
  if [[ $CURRENT_FG != 'NONE' && $1 != $CURRENT_FG ]]; then
    echo -n " %{$fg%F{$CURRENT_FG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$fg%}"
  fi

  CURRENT_FG=$1
  [[ -n $2 ]] && echo -n $2
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_FG ]]; then
    echo -n " %{%k%F{$CURRENT_FG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_FG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
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

prompt_bzr() {
    (( $+commands[bzr] )) || return
    if (bzr status >/dev/null 2>&1); then
        status_mod=`bzr status | head -n1 | grep "modified" | wc -m`
        status_all=`bzr status | head -n1 | wc -m`
        revision=`bzr log | head -n2 | tail -n1 | sed 's/^revno: //'`
        if [[ $status_mod -gt 0 ]] ; then
            prompt_segment 11
            echo -n "bzr@"$revision "✚ "
        else
            if [[ $status_all -gt 0 ]] ; then
                prompt_segment 11
                echo -n "bzr@"$revision
            else
                prompt_segment 10
                echo -n "bzr@"$revision
            fi
        fi
    fi
}

prompt_hg() {
  (( $+commands[hg] )) || return
  local rev st branch
  if $(hg id >/dev/null 2>&1); then
    if $(hg prompt >/dev/null 2>&1); then
      if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        prompt_segment 9
        st='±'
      elif [[ -n $(hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment 11
        st='±'
      else
        # if working copy is clean
        prompt_segment 10
      fi
      echo -n $(hg prompt "☿ {rev}@{branch}") $st
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(hg id -b 2>/dev/null)
      if `hg st | grep -q "^\?"`; then
        prompt_segment 9
        st='±'
      elif `hg st | grep -q "^[MA]"`; then
        prompt_segment 11
        st='±'
      else
        prompt_segment 10
      fi
      echo -n "☿ $rev@$branch" $st
    fi
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
    prompt_segment 9 " ✖  $RETVAL"
  else
    prompt_segment 10 " ✔ "
  fi
}

prompt_aws() {
  [[ -z "$AWS_PROFILE" ]] && return
  prompt_segment 9 "AWS: $AWS_PROFILE"
}

# K8s context and namespace
prompt_k8s() {
  (( $+commands[kubectl] )) || return
  K8S_CONTEXT=`kubectl config current-context`
  K8S_NAMESPACE=`kubectl config view --minify --output 'jsonpath={..namespace}'` 2> /dev/null
  [[ -z "$K8S_CONTEXT" ]] && return
  prompt_segment 12 "⎈ $K8S_CONTEXT:${K8S_NAMESPACE:-default}"
}

prompt_awsvault() {
  [[ -z "$AWS_VAULT" ]] && return
  prompt_segment 9 "🔐  $AWS_VAULT"
}

prompt_docker() {
  local DOCKER_MACHINE=${DOCKER_MACHINE_NAME:-$DOCKER_HOST}
  [[ -z $DOCKER_HOST ]] && return
  prompt_segment 12 "$DOCKER_MACHINE"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_dir
  prompt_virtualenv
  prompt_k8s
  prompt_aws
  prompt_awsvault
  prompt_git
  prompt_bzr
  prompt_hg
  prompt_docker
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
