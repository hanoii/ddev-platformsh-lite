[![tests](https://github.com/hanoii/ddev-platformsh-lite/actions/workflows/tests.yml/badge.svg)](https://github.com/hanoii/ddev-platformsh-lite/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2022.svg)

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
