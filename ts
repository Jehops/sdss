#!/bin/sh

# tmux send to multiple windows

win="1 2 3 4 5 6"

ts() {
  for i in $win; do
    tmux send -t ":$i" -l "$*"
    tmux send -t ":$i" KPEnter
  done
}

ts "$@"
