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

# gif - convert a quicktime movie into a gif
gif() {
  if [ -z "$1" ]; then
    return
  fi
  gif_name=$(echo "$1" | perl -p -e 's/\.(mov|mp4)$/\.gif/g')
  ffmpeg -i "$1" -r 10 -f image2pipe -vcodec ppm - | convert -delay 5 -layers Optimize -loop 0 - "$gif_name"
}

# github push - push the current branch and then open a browser window with the
# PR page open
gp () {
  branch="$(git rev-parse --abbrev-ref HEAD)"
  regex="github\.com:(.*)\.git"
  [[ "$(git remote -v | grep push)" =~ $regex ]]

  git push -u origin "$branch"
  open "https://github.com/${BASH_REMATCH[1]}/compare/$branch?expand=1"
}

# png - build a PNG from the given text
png () {
 echo "$1" | convert label:@- a.png
}

alias npm-exec='PATH=$(npm bin):$PATH'
alias be='bundle exec'

# git auto-completion
if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
  . "$(brew --prefix)/etc/bash_completion"
fi

# terminal display
export PS1="\[\e[0;35m\][\t] \[\e[0;31m\]\u \[\e[0;32m\]\w \[\e[0;34m\]$(gb)\[\e[0m\]$ "

# rbenv config
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# enable terminal colors
export CLICOLOR=1

# configure go
export GOPATH=/usr/local/opt/go/bin
export PATH=$GOPATH/bin:$PATH:/usr/local/opt/go/libexec/bin

# properly configure java 8
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

# configure android home
export ANDROID_HOME=~/Library/Android/sdk/
export PATH=$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$PATH

# set up GPG interface
export GPG_TTY=$(tty)

# set up bundler editor
export BUNDLER_EDITOR=mate
