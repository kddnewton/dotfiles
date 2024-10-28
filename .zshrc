fpath=(~/.zsh/completion $fpath)
autoload -Uz compinit && compinit -i
autoload -U colors && colors
setopt promptsubst

eval $(/opt/homebrew/bin/brew shellenv)
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh

alias be='bundle exec'
alias ..='cd ..'

local branch="$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/@\1 /')"
export PS1="%{$fg[magenta]%}[%*] %{$fg[red]%}%n %{$fg[green]%}% %~ %{$fg[blue]%}% ${branch}%{$reset_color%}% $ "

export BUNDLER_EDITOR=code
export CLICOLOR=1
export EDITOR=code
export GPG_TTY="$(tty)"
export LIBRARY_PATH="$LIBRARY_PATH:$(brew --prefix)/lib"
export PATH="/Users/kddnewton/src/github.com/kddnewton/dotfiles/bin:$PATH"

chruby 3.3.5

# docker clean - remove old images and containers
dcl() {
  docker images | grep "<none>" | awk '{print $3}' | xargs -n 1 docker rmi -f
  docker ps -a | awk '{print $1}' | tail -n +2 | xargs -n 1 docker rm -f
}

# git clean - remove local branches that have been merged remotely
gcl() {
  [ -z "$1" ] && DEL="-D" || DEL="$1"
  git fetch --prune
  git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch "$DEL"
}

# github push - push the current branch and then open a browser window with the
# PR page open
gp() {
  local branch="$(git rev-parse --abbrev-ref HEAD)"
  local regex="github\.com:(.*)\.git"
  [[ "$(git remote -v | grep push | grep origin)" =~ $regex ]]

  git push -u origin "$branch"
  open "https://github.com/${match[1]}/compare/$branch?expand=1"
}

# Load nvm — this is gated behind a function so the init script doesn't get run
# until it's actually needed because it's slow.
nvm() {
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

# Configure CRuby for YJIT development.
rbyjit() {
  ./configure --disable-install-doc --disable-install-rdoc --with-openssl-dir=$(brew --prefix openssl@1.1) --config-cache --disable-shared --enable-yjit=dev --prefix=$HOME/.rubies/ruby-yjit
}
