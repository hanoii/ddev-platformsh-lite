[![tests](https://github.com/hanoii/ddev-platformsh-lite/actions/workflows/tests.yml/badge.svg)](https://github.com/hanoii/ddev-platformsh-lite/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2023.svg)

## What is ddev-platformsh-lite?

This is my own take to platformsh integration, a lite one, for my team's personal
projects.

This addon expects, for authenticated calls, to add an 
[API token][platformsh-api-token] through `config.platformsh.yaml` 
(filename doesn't matter) with the following:

```yaml
web_environment:
  - PLATFORMSH_CLI_TOKEN=<YOUR_CLI_TOKEN>
```

[platformsh-api-token]: https://docs.platform.sh/administration/cli/api-tokens.html

It:

- updates the cli
- set logical environment varials
- generate ssh certs for keyless ssh calls
- add drush aliases
- exposes two (or more) ports to the host so that so one can use 
`ddev platform tunnel:open` (see below)

### platform tunnel:open

This add-on exposes [two ports](docker-compose.platformsh-lite.yaml) which overs
a redis and a database services. If you need to expose more ports and do not
wish to modify/manage this add-on's files you can create `.ddev/.env` file on
your project with the following:

```
# Exposes 30000, 30001, 30002 and 30003
DDEV_PLATFORMSH_LITE_TUNNEL_UPPER_RANGE=30003
```

In order that multiple projects can run at the same time, a random hosts port 
will be used. To find the mapping ones you can use the following host command:

`ddev platform:ports` 
