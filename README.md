[![tests](https://github.com/hanoii/ddev-platformsh-lite/actions/workflows/tests.yml/badge.svg)](https://github.com/hanoii/ddev-platformsh-lite/actions/workflows/tests.yml)
![project is maintained](https://img.shields.io/maintenance/yes/2024.svg)

<!-- toc -->

- [What is ddev-platformsh-lite?](#what-is-ddev-platformsh-lite)
- [platform tunnel:open](#platform-tunnelopen)

<!-- tocstop -->

## What is ddev-platformsh-lite?

This is my own take to platformsh integration, a lite one.

ddev has a first class [Platform.sh integration][ddev-platformsh] and an
[official add-on][ddev-platformsh-addon], but it's too tightly coupled to
everything platform.sh.

[ddev-platformsh]:
  https://ddev.readthedocs.io/en/stable/users/providers/platform/
[ddev-platformsh-addon]: https://github.com/ddev/ddev-platformsh

This addon needs an [API token][platformsh-api-token] through
`config.local.yaml` with the following:

```yaml
web_environment:
  - PLATFORMSH_CLI_TOKEN=<YOUR_CLI_TOKEN>
```

[platformsh-api-token]:
  https://docs.platform.sh/administration/cli/api-tokens.html

Add-on features:

- Updates the cli
- Set logical environment variables
- Generate ssh certs for keyless ssh calls
- Add drush aliases if project is drupal
- Exposes two (or more) ports to the host so that so one can use
  `ddev platform tunnel:open` (see below)
- Check for existance of needed environment variables
- Special ssh key/cert handling
  - Adds certificates to ddev's ssh agent automatically
  - Optionaly configures ssh to forward agent keys on platform.sh domains. If
    you want need this to happen automatically all the time, please add
    `DDEV_PLATFORMSH_LITE_SSH_FORWARDAGENT=true` to your project's `config.yaml`
    or alternatively to `config.local.yaml`

## platform tunnel:open

This add-on exposes [two ports](docker-compose.platformsh-lite.yaml) (30000
and 30001) which covers a redis and a database services. If you need to expose
more ports a nd do not wish to modify/manage this add-on's files you can create
`.ddev/.env` file on your project with the following:

```
# Exposes 30000, 30001, 30002 and 30003
DDEV_PLATFORMSH_LITE_TUNNEL_UPPER_RANGE=30003
```

In order that multiple projects can run at the same time, a random hosts port
will be used. To find the mapping ones you can use the following host command
that will output properly formatted urls for each platform service:

```
ddev platform:tunnels
```
