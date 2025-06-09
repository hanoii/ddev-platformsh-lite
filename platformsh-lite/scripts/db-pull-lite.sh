#!/bin/bash
#ddev-generated
set -e -o pipefail

USAGE=$(cat << EOM
Usage: ${DDEV_PLATFORMSH_LITE_HELP_CMD-$0} [options]

  -h                This help text.
  -A APP            Specify the app to pull database from (optional).
  -e ENVIRONMENT    Specify the environment to pull database from.
  -r RELATIONSHIP   Specify the database relationship to pull from.
  -p PROJECT        Specify a Platform.sh project to pull from.
  -f FILENAME       Specify a custom dump filename (optional).
  -n                Do not download, expect the dump to be already downloaded.
  -o                Import only, do not run post-import-db hooks.
EOM
)

function print_help() {
  gum style --border "rounded" --margin "1 2" --padding "1 2" "$@" "$USAGE"
}

# Default values
app=""
environment=""
relationship=""
project=""
filename=""
download=true
post_import=true

while getopts ":hA:e:r:p:f:no" option; do
  case ${option} in
    h)
      print_help
      exit 0
      ;;
    A)
      app=$OPTARG
      ;;
    e)
      environment=$OPTARG
      ;;
    r)
      relationship=$OPTARG
      ;;
    p)
      project=$OPTARG
      ;;
    f)
      filename=$OPTARG
      ;;
    n)
      download=false
      ;;
    o)
      post_import=false
      ;;
    :)
      gum log --level fatal -- "Option '-${OPTARG}' requires an argument."
      echo "$USAGE"
      exit 1
      ;;
    ?)
      gum log --level fatal -- "Invalid option: -${OPTARG}."
      echo "$USAGE"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [[ -z "$environment" ]]; then
  gum log --level fatal "Environment (-e) is required."
  echo "$USAGE"
  exit 1
fi

if [[ -z "$relationship" ]]; then
  gum log --level fatal "Relationship (-r) is required."
  echo "$USAGE"
  exit 1
fi

# Build platform command arguments
cmd_project=""
if [[ -n "$project" ]]; then
  cmd_project="--project=$project"
fi

cmd_app=""
if [[ -n "$app" ]]; then
  cmd_app="-A $app"
fi

# Check if project is accessible
if [[ -z "$project" ]] && ! platform project:info --no-interaction > /dev/null 2>&1; then
  gum log --level fatal "Platform project not found, please specify it through -p."
  exit 1
fi

gum log --level info "Environment: $environment"
gum log --level info "Relationship: $relationship"

# Set filename if not provided via -f option
if [[ -z "$filename" ]]; then
  filename=dump-${relationship}-$environment.sql.gz
fi

gum log --level info "Creating $filename..."

if [[ "$download" == "true" ]]; then
  # Detect structure tables for Drupal projects
  structure_tables=""
  cmd_structure_tables=""
  cmd_exclude_tables=""

  if [[ -n "${DDEV_PLATFORMSH_LITE_DRUSH_SQL_EXCLUDE}" ]]; then
    structure_tables=$DDEV_PLATFORMSH_LITE_DRUSH_SQL_EXCLUDE
  elif [[ "$DDEV_PROJECT_TYPE" == *"drupal"* ]] || [[ "$DDEV_BROOKSDIGITAL_PROJECT_TYPE" == *"drupal"* ]]; then
    if ! structure_tables=$(gum spin --show-output --title="Drupal project type, finding schema only tables..." -- platform -y $cmd_project db:sql $cmd_app -r ${relationship} -e $environment "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND (TABLE_NAME LIKE 'cache%' OR TABLE_NAME LIKE 'watchdog') ORDER BY TABLE_NAME" --raw | awk 'FNR > 1 {print}' | sed -z 's/\n/,/g' | sed 's/,$//'); then
      gum log --level fatal "Failed to find schema only tables."
      exit 1
    fi
    gum log --level debug "Schema only tables: $structure_tables"
  fi

  # Build table exclusion commands
  if [[ -n "$structure_tables" ]]; then
    IFS=',' read -r -a structure_tables_array <<< "$structure_tables"
    for t in "${structure_tables_array[@]}"; do
      cmd_structure_tables+="--table=$t "
      cmd_exclude_tables+="--exclude-table=$t "
    done

    temp_filename=$(mktemp)
    temp_filename_schema=$(mktemp)
    temp_filename_data=$(mktemp)

    gum spin --show-output --title="Dumping schema only tables..." -- platform $cmd_project -y db:dump $cmd_app -r ${relationship} -e $environment $cmd_structure_tables --schema-only --gzip -o > $temp_filename_schema
    gum spin --show-output --title="Dumping data tables..." -- platform $cmd_project -y db:dump $cmd_app -r ${relationship} -e $environment $cmd_exclude_tables --gzip -o > $temp_filename_data

    # Combine schema and data dumps, removing MariaDB sandbox mode comments
    cat $temp_filename_schema | gunzip | tail +2 | gzip > $temp_filename
    cat $temp_filename_data | gunzip | tail +2 | gzip >> $temp_filename
    rm -f $filename
    mv $temp_filename $filename

    # Clean up temp files
    rm -f $temp_filename_schema $temp_filename_data
  else
    # Simple dump without table exclusions
    gum spin --show-output --title="Dumping database..." -- platform $cmd_project -y db:dump $cmd_app -r ${relationship} -e $environment --gzip -o > $filename
  fi
else
  if [[ ! -f $filename ]]; then
    gum log --level error "Dump ${filename} not found. Please run it without -n."
    exit 3
  fi
fi

# Import the database
gum log --level info "Importing database..."
mysql -uroot -proot -e 'DROP DATABASE IF EXISTS db' mysql
mysql -uroot -proot -e 'CREATE DATABASE db' mysql
pv $filename | gunzip | mysql

if [[ "$post_import" == "true" ]]; then
  # Run all post-import-db scripts if they exist
  post_import_script="/var/www/html/.ddev/pimp-my-shell/hooks/post-import-db.sh"
  if [[ -f "$post_import_script" ]]; then
    gum log --level info "Running post-import hooks..."
    $post_import_script $cmd_app -r ${relationship} -e $environment
  else
    gum log --level debug "No post-import script found at $post_import_script"
  fi
fi

gum log --level info "Database import completed successfully!"
