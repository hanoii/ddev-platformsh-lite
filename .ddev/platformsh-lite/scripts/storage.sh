#!/bin/bash
#ddev-generated
set -e -o pipefail

USAGE=$(cat << EOM
Usage: ${DDEV_PLATFORMSH_LITE_HELP_CMD-$0} [-e ENV] [PROJECT_ID...]
       ${DDEV_PLATFORMSH_LITE_HELP_CMD-$0} [-e ENV] --all

Show subscription storage vs. storage allocated to (and used by) each app and
service. Everything is fetched from the Platform.sh CLI/API, nothing is read
from local files.

  -h                This help text.
  -e ENV            Environment to inspect. Defaults to each project's default branch.
  --all             Traverse every project listed by 'platform projects'.
  PROJECT_ID        One or more project ids. Defaults to the current project.

Percentages are colored: magenta >= 75%, yellow >= 80%, red >= 90%.
EOM
)

environment=""
all=0
projects=()
while [ $# -gt 0 ]; do
  case "$1" in
    -e|--environment) environment="$2"; shift 2 ;;
    -e=*|--environment=*) environment="${1#*=}"; shift ;;
    --all) all=1; shift ;;
    -h|--help) echo "$USAGE"; exit 0 ;;
    -*) gum log --level error "Unknown option: $1"; echo "$USAGE"; exit 1 ;;
    *) projects+=("$1"); shift ;;
  esac
done

if [ "$all" = 1 ]; then
  mapfile -t projects < <(gum spin --show-output --title="Querying projects on Platform.sh..." -- \
    platform projects --format=plain --columns=id --no-header --count 0)
elif [ ${#projects[@]} -eq 0 ]; then
  projects=("$(platform project:info id)")
fi

report() {
  local project_id=$1 env=$2 title subscription_mb deployment usage allocated_mb

  title=$(platform project:info title -p "$project_id" 2>/dev/null || echo "?")
  [ -n "$env" ] || env=$(platform project:info default_branch -p "$project_id")

  gum style --bold --foreground 212 "$title ($project_id) - environment: $env"

  subscription_mb=$(platform subscription:info storage -p "$project_id" 2>/dev/null || echo null)

  # Allocated disk (MB) per app/service, as currently deployed on the environment.
  if ! deployment=$(platform api:curl -f "/projects/$project_id/environments/$env/deployments/current" 2>/dev/null); then
    gum log --level warn "No current deployment for $project_id/$env (inactive environment?)"
    echo
    return
  fi

  # Actual usage from the metrics API. Services without disk have empty columns.
  usage=$(platform disk --latest --no-header --format=tsv \
    --columns=service,used,limit,percent -p "$project_id" -e "$env" 2>/dev/null || true)

  allocated_mb=$(echo "$deployment" | jq '[.webapps[], .services[] | .disk // 0] | add')

  echo "$deployment" | jq -r --arg usage "$usage" '
    def row(kind): to_entries[] | {name: .key, kind: kind, type: .value.type, disk: (.value.disk // 0)};
    def or_dash: if . == null or . == "" then "-" else . end;
    def colorize: (rtrimstr("%") | tonumber? // 0) as $n
      | if $n >= 90 then "\u001b[31m\(.)\u001b[0m" elif $n >= 80 then "\u001b[33m\(.)\u001b[0m" elif $n >= 75 then "\u001b[35m\(.)\u001b[0m" else . end;
    ($usage | split("\n") | map(select(length > 0) | split("\t")
      | {key: .[0], value: {used: .[1], limit: .[2], percent: .[3]}}) | from_entries) as $u
    | (["NAME", "KIND", "TYPE", "ALLOCATED", "USED", "LIMIT", "USED%"] | @tsv),
      ((.webapps | row("app")), (.services | row("service"))
        | [.name, .kind, .type, "\(.disk) MB",
           ($u[.name].used | or_dash), ($u[.name].limit | or_dash), ($u[.name].percent | or_dash | colorize)] | @tsv)
  ' | column -t -s $'\t'

  jq -rn --argjson sub "$subscription_mb" --argjson alloc "$allocated_mb" '
    def gb: . / 1024 * 100 | round / 100;
    def colorize: (rtrimstr("%") | tonumber? // 0) as $n
      | if $n >= 90 then "\u001b[31m\(.)\u001b[0m" elif $n >= 80 then "\u001b[33m\(.)\u001b[0m" elif $n >= 75 then "\u001b[35m\(.)\u001b[0m" else . end;
    "",
    (if $sub == null then
      "Subscription storage: unknown (no access to subscription)",
      "Allocated:            \($alloc) MB (\($alloc | gb) GB)"
    else
      "Subscription storage: \($sub) MB (\($sub | gb) GB)",
      "Allocated:            \($alloc) MB (\($alloc | gb) GB) = \("\($alloc / $sub * 10000 | round / 100)%" | colorize) of subscription",
      "Free to allocate:     \($sub - $alloc) MB (\(($sub - $alloc) | gb) GB)"
    end),
    ""
  '
}

for project_id in "${projects[@]}"; do
  report "$project_id" "$environment"
done
