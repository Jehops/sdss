#!/bin/sh

# This is deprecated.  Conkeror is EOL.  Use xdg-open.

#GTK2_RC_FILES=~/.gtkrc-2.0.conkeror exec xulrunner /home/jrm/scm/nm/conkeror.git/application.ini "$@"
#GTK2_RC_FILES=~/.gtkrc-2.0.conkeror firefox -app "${HOME}/scm/nm/conkeror.git/application.ini" "$@"
#GTK2_RC_FILES=~/.gtkrc-2.0.conkeror exec palemoon -app /home/jrm/scm/nm/conkeror.git/application.ini "$@"
GTK2_RC_FILES=~/.gtkrc-2.0.conkeror waterfox -app "${HOME}/scm/nm/conkeror.git/application.ini" "$@"
