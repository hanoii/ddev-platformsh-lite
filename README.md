[![tests](https://github.com/hanoii/ddev-platformsh-lite/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/hanoii/ddev-platformsh-lite/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/hanoii/ddev-platformsh-lite)](https://github.com/hanoii/ddev-platformsh-lite/commits)
![project is maintained](https://img.shields.io/maintenance/yes/2026.svg)

<!-- toc -->

- [What is ddev-platformsh-lite?](#what-is-ddev-platformsh-lite)
- [Installation](#installation)
- [Configuration](#configuration)
- [Features](#features)
- [Platform.sh Tunnels](#platformsh-tunnels)
- [Database Operations](#database-operations)
- [SSH Configuration](#ssh-configuration)
- [Troubleshooting](#troubleshooting)

<!-- tocstop -->

## What is ddev-platformsh-lite?

A lightweight Platform.sh integration for DDEV that provides essential
functionality without the tight coupling of the official integration.

> [!NOTE]
> [Platform.sh is now Upsun](https://upsun.com/platform-sh-is-now-upsun/), and
> the Platform.sh offering is called Upsun Fixed. The `platform` CLI and the
> `PLATFORM_*`/`PLATFORMSH_*` environment variables this add-on relies on keep
> working, and the
> [Upsun Fixed CLI docs](https://fixed.docs.upsun.com/administration/cli.html)
> still document them. This add-on keeps the Platform.sh naming for now.

Unlike the
[official Platform.sh integration](https://docs.ddev.com/en/stable/users/providers/platform/)
and [add-on](https://github.com/ddev/ddev-platformsh), this add-on focuses on
core functionality while remaining lightweight and flexible.

## Installation

This add-on depends on
[hanoii/ddev-pimp-my-shell](https://github.com/hanoii/ddev-pimp-my-shell),
install it first:

```bash
ddev add-on get hanoii/ddev-pimp-my-shell
ddev add-on get https://github.com/hanoii/ddev-platformsh-lite/tarball/main
```

The `ahoy` commands are exposed under `ahoy platform`. If your project does not
have a root `.ahoy.yml` yet, copy `.ddev/platformsh-lite/.ahoy.ifnotpresent.yml`
to `.ahoy.yml`. Otherwise, add the import to your existing one:

```yaml
commands:
  platform:
    usage: "Platform commands"
    imports:
      - .ddev/platformsh-lite/.ahoy.platformsh-lite.yml
```

## Configuration

This addon requires a Platform.sh
[API token](https://fixed.docs.upsun.com/administration/cli/api-tokens.html).
Add it to your project's `config.local.yaml`:

```yaml
web_environment:
  - PLATFORMSH_CLI_TOKEN=<YOUR_CLI_TOKEN>
```

Optionally, specify a default Platform.sh project in your `config.yaml`:

```yaml
web_environment:
  - PLATFORM_PROJECT=your-project-id
```

## Features

- **CLI Management**: Automatically updates the Platform.sh CLI
- **Environment Variables**: Sets logical environment variables for Platform.sh
  integration
- **SSH Configuration**: Generates SSH certificates for keyless connections
- **Drush Integration**: Adds Drush aliases for Drupal projects
- **Service Tunnels**: Exposes ports to access Platform.sh services locally
- **Database Operations**: Simplified database pull commands with smart defaults

## Platform.sh Tunnels

Access Platform.sh services (databases, Redis, etc.) directly from your local
environment:

1. **Open tunnels**:

   ```bash
   ddev platform tunnel:open
   ```

2. **View connection details**:
   ```bash
   ddev platform:tunnels
   ```

By default, ports 30000-30001 are exposed. Need more? Create `.ddev/.env` with:

```
# Exposes ports 30000 through 30003
DDEV_PLATFORMSH_LITE_TUNNEL_UPPER_RANGE=30003
```

## Database Operations

Pull databases from Platform.sh environments:

```bash
# Interactive database pull with smart defaults
ddev ahoy platform db:pull

# Specify environment
ddev ahoy platform db:pull -e staging

# Basic database pull, requires environment and relationship
ddev ahoy platform db:pull:lite -e main -r database
```

Other `ahoy platform` commands:

- `push:log`: show the latest push activity log, `-w` waits for one in progress
- `activities`: choose an activity to log (excluding cron/backups)
- `storage`: subscription storage vs. allocated/used per app and service, fetched
  from the Platform.sh API. Accepts project ids, `-e ENV`, or `--all` to walk
  every project
- `switch`: select a different project to run `platform` commands against

## SSH Configuration

The addon handles SSH keys and certificates automatically:

- Adds Platform.sh certificates to DDEV's SSH agent
- Optionally forwards agent keys on Platform.sh domains

To enable SSH agent forwarding, add to your `config.yaml` or
`config.local.yaml`:

```yaml
web_environment:
  - DDEV_PLATFORMSH_LITE_SSH_FORWARDAGENT=true
```

## Troubleshooting

If you encounter issues with tunnels:

1. Check if you have enough ports exposed:

   ```bash
   ddev platform:tunnels
   ```

2. If you see warnings about unexposed ports, increase the port range as
   described in the [Platform.sh Tunnels](#platformsh-tunnels) section.

3. Verify your Platform.sh token is valid:
   ```bash
   ddev platform auth:info
   ```
