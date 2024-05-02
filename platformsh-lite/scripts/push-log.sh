#!/bin/bash
#ddev-generated
set -e -o pipefail

PENDING=$(platform activities --type environment.push --all --state=pending --format=plain --columns=id --no-header "$@" 2> /dev/null | wc -l)

ACTIVITY=$(platform activities --type environment.push --limit 1 --state=in_progress --format=plain --columns=id --no-header "$@")
if [ $PENDING -gt 0 ]; then
  gum log --level warn "There are still $PENDING pending builds"
  sleep 1
fi

if [ -n "$ACTIVITY" ]; then
  gum log --level info "Showing the current in_progress build"
  platform activity:log $ACTIVITY
else
  gum log --level error "There's no push in progress to log"
fi
