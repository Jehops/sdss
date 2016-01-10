#!/bin/sh

## Make Emacs handle mailto URIs.

emacsclient -e "(browse-url-mail \"${@}\")"
