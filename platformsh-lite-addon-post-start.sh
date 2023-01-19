#!/bin/bash
#ddev-generated

FILENAME=/tmp/platform-sh-lite-addon-post-start
if [ -f "$FILENAME" ] ; then
  echo "platformsh-lite add-on post start script has already been run!"
  rm "$FILENAME"
  exit
fi

touch $FILENAME

# Update to the latest version
platform self:update -qy --no-major || true

# Install shell integration to avoid prompt
platform self:install -qy || true

# Cert load
([ ! -z "${PLATFORMSH_CLI_TOKEN:-}" ] && platform ssh-cert:load -y) || true

if [[ "$PLATFORM_PROJECT" != "" ]] && [[ ! -d .platform/local ]]; then
  printf "✔ Setting remote project to $PLATFORM_PROJECT"
  platform project:set-remote $PLATFORM_PROJECT
fi

# And create drush aliases
if [[ "$DDEV_PROJECT_TYPE" == *"drupal"* ]]; then
  ([ ! -z "${PLATFORMSH_CLI_TOKEN:-}" ] && platform drush-aliases -r -g ${DDEV_PROJECT} -y) || true
fi
