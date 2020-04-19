# quick directory traversal
.. () {
  cd ..
  for dir in "$@"; do
    cd "$dir"
  done
}

# docker clean - remove old images and containers
dcl () {
  docker images | grep "<none>" | awk '{print $3}' | xargs -n 1 docker rmi -f
  docker ps -a | awk '{print $1}' | tail -n +2 | xargs -n 1 docker rm -f
}

# git branch - get the current branch of the working directory
gb () {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/@\1 /'
}

# git clean - remove local branches that have been merged remotely
gcl () {
  [ -z "$1" ] && DEL="-D" || DEL="$1"
  git fetch --prune
  git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch "$DEL"
}

# github push - push the current branch and then open a browser window with the
# PR page open
gp () {
  local branch="$(git rev-parse --abbrev-ref HEAD)"
  local regex="github\.com:(.*)\.git"
  [[ "$(git remote -v | grep push)" =~ $regex ]]

  git push -u origin "$branch"
  open "https://github.com/${match[1]}/compare/$branch?expand=1"
}

# png - build a PNG from the given text
png () {
 echo "$1" | convert label:@- a.png
}

fpath=(~/.zsh/completion $fpath)
autoload -Uz compinit && compinit -i

alias be='bundle exec'
alias ne='PATH=$(npm bin):$PATH'
alias mate='code'

autoload -U colors && colors
setopt promptsubst

local branch='$(gb)'
export PS1="%{$fg[magenta]%}[%*] %{$fg[red]%}%n %{$fg[green]%}% %~ %{$fg[blue]%}% ${branch}%{$reset_color%}% $ "

export BUNDLER_EDITOR=code
export CLICOLOR=1
export EDITOR=vim
export GPG_TTY="$(tty)"
