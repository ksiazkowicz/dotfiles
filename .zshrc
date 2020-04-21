os=`uname -s`

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH
export GOPATH=$HOME/go
ZSH_CUSTOM=$HOME/Development/dotfiles/zsh

# Mac specific stuff
if [ $os = 'Darwin' ]; then
  export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"

  # Setting PATH for Python 3.7
  export PATH="/usr/local/Cellar/python/3.7.3/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"

  # Add Visual Studio Code (code)
  export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
else
  [ -s "/home/linuxbrew/.linuxbrew/bin/brew" ] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) 
fi

# Poetry
export PATH="$HOME/.poetry/bin:$PATH"

# lazyload virtualenvwrapper if available
if (( $+commands[virtualenvwrapper.sh] )); then
  export WORKON_HOME=$HOME/Envs
  export PROJECT_HOME=$HOME/Development
  export VIRTUALENVWRAPPER_PYTHON=$(which python3)
  export PATH="/usr/local/opt/openssl/bin:$PATH"
  export VIRTUAL_ENV_DISABLE_PROMPT=1

  if [[ ! $(typeset -f workon) ]]; then
    declare -a __virtualenv_commands=('workon' 'mkvirtualenv')
    __load_virtualenv() {
      for i in "${__virtualenv_commands[@]}"; do unalias $i; done
      source "$(which virtualenvwrapper.sh)"
      unset __virtualenv_commands
      unset -f __load_virtualenv
    }
    for i in "${__virtualenv_commands[@]}"; do alias $i='__load_virtualenv && '$i; done
  fi
fi

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
if (( $+commands[pyenv] )); then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="chleb"
ZSH_DISABLE_COMPFIX="true"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git docker docker-compose docker-machine ksiazkowicz-helpers
    zsh-syntax-highlighting virtualenvwrapper node npm history
    brew zsh-aws-vault zsh-kubectl-prompt
)

source $ZSH/oh-my-zsh.sh

# User configuration

export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTFILE=~/.zhistory

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='vim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias k="kubectl"
alias kx="kubectx"
alias kn="kubens"
alias kl="stern"

[ -s "$HOME/.aliases.zsh" ] && source ~/.aliases.zsh

# Dircolors
eval $(dircolors ~/.dircolors)
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Completions
export BASH_COMPLETION_COMPAT_DIR=/usr/local/etc/bash_completion.d
[ -s "/usr/local/etc/profile.d/bash_completion.sh" ] && . /usr/local/etc/profile.d/bash_completion.sh

# custom completions
fpath=($ZSH_CUSTOM/completions $fpath)

# lazyload kubectl completion
function kubectl() {
  if ! type __start_kubectl >/dev/null 2>&1; then
    source <(command kubectl completion zsh)
  fi

  command kubectl "$@"
}

# Defer initialization of nvm until nvm, node or a node-dependent command is
# run. Ensure this block is only run once if .zshrc gets sourced multiple times
# by checking whether __init_nvm is a function.
export NVM_DIR="$HOME/.nvm"
NVM_PATH="/usr/local/opt/nvm/nvm.sh"
[ -s "$NVM_DIR/nvm.sh" ] && NVM_PATH="$NVM_DIR/nvm.sh"
if [ -s "$NVM_PATH" ] && [ ! "$(typeset -f __init_nvm)" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
  declare -a __node_commands=('nvm' 'node' 'npm' 'yarn' 'gulp' 'grunt' 'webpack')
  function __init_nvm() {
    for i in "${__node_commands[@]}"; do unalias $i; done
    . $NVM_PATH
    unset __node_commands
    unset -f __init_nvm
  }
  for i in "${__node_commands[@]}"; do alias $i='__init_nvm && '$i; done
fi

## completion stuff
zstyle ':compinstall' filename '$HOME/.zshrc'

zcachedir="$HOME/.zcache"
[[ -d "$zcachedir" ]] || mkdir -p "$zcachedir"

_update_zcomp() {
    setopt local_options
    setopt extendedglob
    autoload -Uz compinit
    local zcompf="$1/zcompdump"
    # use a separate file to determine when to regenerate, as compinit doesn't
    # always need to modify the compdump
    local zcompf_a="${zcompf}.augur"

    if [[ -e "$zcompf_a" && -f "$zcompf_a"(#qN.md-1) ]]; then
        compinit -C -d "$zcompf"
    else
        compinit -d "$zcompf"
        touch "$zcompf_a"
    fi
    # if zcompdump exists (and is non-zero), and is older than the .zwc file,
    # then regenerate
    if [[ -s "$zcompf" && (! -s "${zcompf}.zwc" || "$zcompf" -nt "${zcompf}.zwc") ]]; then
        # since file is mapped, it might be mapped right now (current shells), so
        # rename it then make a new one
        [[ -e "$zcompf.zwc" ]] && mv -f "$zcompf.zwc" "$zcompf.zwc.old"
        # compile it mapped, so multiple shells can share it (total mem reduction)
        # run in background
        zcompile -M "$zcompf" &!
    fi
}
_update_zcomp "$zcachedir"
unfunction _update_zcomp

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
