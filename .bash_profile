boot_docker_machine () {
  if [[ $(docker-machine status default) == 'Stopped' ]]; then
    docker-machine start default
  fi
}
dc () {
  docker images | grep "<none>" | awk '{print $3}' | xargs -n 1 docker rmi -f
  docker ps -a | awk '{print $1}' | tail -n +2 | xargs -n 1 docker rm -f
}
gb () {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/@\1 /'
}
gcl () {
  git fetch --prune
  git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -d
}
gp () {
  branch="$(git rev-parse --abbrev-ref HEAD)"
  regex="github\.com:(.*)\.git"
  [[ "$(git remote -v | grep push)" =~ $regex ]]

  git push -u origin $branch
  open "https://github.com/${BASH_REMATCH[1]}/compare/$branch?expand=1"
}

TIMESTAMP='\[\e[0;35m\][\t] '
USER_NAME='\[\e[0;31m\]\u '
LOCATION='\[\e[0;32m\]\w'
GIT_BRANCH=' \[\e[0;34m\]$(gb)\[\e[0m\]'
export PS1="$TIMESTAMP$USER_NAME$LOCATION$GIT_BRANCH$ "

alias docker-env='$(boot_docker_machine); eval $(docker-machine env default)'
alias npm-exec='PATH=$(npm bin):$PATH'
alias be='bundle exec'

to_gif() {
  if [ -z "$1" ]; then
    return
  fi
  gif_name=`echo "$1" | perl -p -e 's/\.(mov|mp4)$/\.gif/g'`
  ffmpeg -i "$1" -r 10 -f image2pipe -vcodec ppm - |\
    convert -delay 5 -layers Optimize -loop 0 - "$gif_name"
}

# git auto-completion
if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

# rbenv config
eval "$(rbenv init -)"

# load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# enable terminal colors
export CLICOLOR=1

# configure go
export GOPATH=/usr/local/opt/go/bin
export PATH=$GOPATH/bin:$PATH:/usr/local/opt/go/libexec/bin
