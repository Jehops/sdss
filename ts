#!/bin/sh

# tmux send to multiple windows

. "$HOME/.ts.conf"

ts() {
  for i in $win; do
    tmux send -t ":$i" -l "$*"
    tmux send -t ":$i" KPEnter
  done
}

ts "$@"
