#!/bin/sh

## Setting thread_queue_size to values larger then the default of 8
## avoids dropped packets.
##
## The option -af aresample=async=1:first_pts=0 means stretch and
## squeeze the audio to synchronize with the video.

usage() { printf "Usage: sc <filename_without_extension>\n"; exit; }

[ $# -ne 1 ] && usage

ffmpeg -video_size 1366x768 \
       -framerate 25 \
       -thread_queue_size 128 -f x11grab -i :0.0+0,0 \
       -thread_queue_size 128 -f oss -i /dev/dsp0 \
       -vcodec libx264rgb -crf 0 -preset:v ultrafast \
       -acodec pcm_s16le \
       -af aresample=async=1:first_pts=0 \
       -y \
       "$1".mkv
