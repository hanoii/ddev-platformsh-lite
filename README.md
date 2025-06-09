[![tests](https://github.com/hanoii/ddev-platformsh-lite/actions/workflows/tests.yml/badge.svg)](https://github.com/hanoii/ddev-platformsh-lite/actions/workflows/tests.yml)
![project is maintained](https://img.shields.io/maintenance/yes/2024.svg)

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

Unlike the
[official Platform.sh integration](https://ddev.readthedocs.io/en/stable/users/providers/platform/)
and [add-on](https://github.com/ddev/ddev-platformsh), this add-on focuses on
core functionality while remaining lightweight and flexible.

## Installation

```bash
ddev get hanoii/ddev-platformsh-lite
```

## Configuration

This addon requires a Platform.sh
[API token](https://docs.platform.sh/administration/cli/api-tokens.html). Add it
to your project's `config.local.yaml`:

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
ddev exec ahoy platform db:pull

# Specify environment
ddev exec ahoy platform db:pull -e staging

# Basic database pull (download only)
ddev exec ahoy platform db:pull:lite
```

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
   ddev exec platform auth:info
   ```
