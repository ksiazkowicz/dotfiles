
# Setting PATH for Python 3.7
# The original version is saved in .bash_profile.pysave
PATH="/usr/local/Cellar/python/3.7.3/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
export PATH
# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Aliases
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'
alias kl='stern'

# Completions
export BASH_COMPLETION_COMPAT_DIR=/usr/local/etc/bash_completion.d
source /usr/local/etc/profile.d/bash_completion.sh
source <(~/Development/dotfiles/posh/Completions/*)

# virtualenvwrapper
export WORKON_HOME=$HOME/Envs
export PROJECT_HOME=$HOME/devel
export VIRTUALENVWRAPPER_PYTHON=$(which python3)
source /usr/local/Cellar/python/3.7.3/Frameworks/Python.framework/Versions/3.7/bin/virtualenvwrapper.sh
export PATH="/usr/local/opt/openssl/bin:$PATH"
