#!/bin/sh
#GTK2_RC_FILES=~/.gtkrc-2.0.conkeror exec xulrunner /home/jrm/scm/nm/conkeror.git/application.ini "$@"
GTK2_RC_FILES=~/.gtkrc-2.0.conkeror firefox -app /home/jrm/scm/nm/conkeror.git/application.ini "$@"
