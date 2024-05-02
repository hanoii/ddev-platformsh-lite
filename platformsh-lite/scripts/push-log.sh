#!/bin/bash
#ddev-generated
set -e -o pipefail

PENDING=$(platform activities --type environment.push --all --state=pending --format=plain --columns=id --no-header "$@" 2> /dev/null || true | wc -l)
state_flag=
if [ $PENDING -gt 0 ]; then
  gum log --level warn "There are still $PENDING pending builds"
  state_flag="--state=in_progress"
fi

ACTIVITY=$(platform activities --type environment.push --limit 1 $state_flag --format=plain --columns=id --no-header "$@")
if [ -n "$ACTIVITY" ]; then
  gum log --level info "Showing the current in progress or latest completed build"
  platform activity:log $ACTIVITY
else
  gum log --level error "There's no push in progress to log"
fi
