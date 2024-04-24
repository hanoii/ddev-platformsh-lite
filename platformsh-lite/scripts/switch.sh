#ddev-generated
#!/bin/bash

if [[ "$0" == *"switch.sh"* ]]; then
  gum log --level error The script is meant to be source\'d.
  if [ -n "$IS_FISH_SHELL" ]; then
    cmd="bass source ./.ddev/platformsh-lite/scripts/switch.sh"
  else
    cmd="source ./.ddev/platformsh-lite/scripts/switch.sh"
  fi
  gum log Please run \'$cmd\' on your shell
  exit 2
fi

IFS=$'\n' projects=$(gum spin --show-output --title="Querying active projects on Platform.sh..." -- platform projects --format=plain --columns=title,id --no-header --count 0)
projects_array=()
for p in $projects; do
  IFS=$'\t' read pname pid <<< $p
  projects_array+=("$pname - $pid")
done

if [ -z "$projects" ] || ! project=$(gum filter --select-if-one --header="Choose project to switch to for running platform commands against" ${projects_array[@]}); then
  gum log --level error --structured "Querying platform projects"
  (exit 2)
else
  project_id=${project#*" - "}

  gum log --level info --structured "Project selected" project $project
  if [[ "$0" == *"switch.sh"* ]]; then
    gum log --level warn The script has been called by the shell so it cannot export environment variable
    gum style "You can run 'export PLATFORM_PROJECT=' on your shell"
    gum style "or source this script instead, by doing 'source ./.ddev/platformsh-lite/scripts/switch.sh'"
    gum log --level warn "It will only be valid in the running shell."
  else
    gum log --level info --structured "Variable PLATFORM_PROJECT exported." project $project_id
    gum log --level warn "It will only be valid in the running shell."
    export PLATFORM_PROJECT=$project_id
  fi
  export PLATFORM_PROJECT=$project_id
fi
