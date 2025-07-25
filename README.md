# docker-luacheck

![](./docs/docker_luacheck.png)

[![Release Build](https://github.com/RagedUnicorn/docker-luacheck/actions/workflows/docker_release.yml/badge.svg)](https://github.com/RagedUnicorn/docker-luacheck/actions/workflows/docker_release.yml)
[![Test](https://github.com/RagedUnicorn/docker-luacheck/actions/workflows/test.yml/badge.svg)](https://github.com/RagedUnicorn/docker-luacheck/actions/workflows/test.yml)
![License: MIT](docs/license_badge.svg)

> Docker Alpine image with Luacheck - A tool for linting and static analysis of Lua code.

![](./docs/alpine_linux_logo.svg)

## Overview

This Docker image provides a lightweight Luacheck installation on Alpine Linux. Luacheck is a static analyzer and a linter for Lua that detects various issues such as usage of undefined global variables, unused variables and values, accessing uninitialized variables, unreachable code and more.

## Features

- **Small footprint**: ~15MB runtime image using Alpine Linux
- **Luacheck 1.2.0**: Latest stable version
- **Multi-stage build**: Optimized for minimal final image size
- **Volume mounting**: Easy file input through `/workspace`
- **Non-root execution**: Runs as dedicated user for security

## Quick Start

```bash
# Pull the image
docker pull ragedunicorn/luacheck:latest

# Run Luacheck on a single file
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest myfile.lua

# Run Luacheck on a directory
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest .
```

For development and building from source, see [DEVELOPMENT.md](DEVELOPMENT.md).

## Usage

The container uses Luacheck as the entrypoint, so any Luacheck parameters can be passed directly to the `docker run` command.

### Basic Usage

```bash
# Using latest version
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest [luacheck-options]

# Using specific Luacheck version (latest Alpine build)
docker run -v $(pwd):/workspace ragedunicorn/luacheck:1.2.0 [luacheck-options]

# Using exact version combination
docker run -v $(pwd):/workspace ragedunicorn/luacheck:1.2.0-alpine3.22.1-1 [luacheck-options]
```

### Examples

#### Check a Single File
```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest myfile.lua
```

#### Check All Lua Files in Directory
```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest .
```

#### Check with Custom Configuration
```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest --config .luacheckrc .
```

#### Generate Report in Different Format
```bash
# TAP format
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest --formatter TAP .

# JUnit XML format
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest --formatter JUnit .

# JSON format
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest --formatter json .
```

#### Ignore Specific Warnings
```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest --ignore 212 --ignore 213 .
```

#### Set Global Variables
```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest --globals love --globals game .
```

## Docker Compose Usage

This repository includes Docker Compose configurations for easier usage and common linting workflows.

### Basic Setup

1. Place your Lua files in your project directory

2. Run Luacheck using docker compose:
```bash
docker compose run --rm luacheck .
```

### Example Configurations

The `examples/` directory contains specialized docker-compose files for common tasks:

#### Project Linting (`examples/docker-compose.lint.yml`)
```bash
# Lint entire project
docker compose -f examples/docker-compose.lint.yml run --rm lint-project

# Lint with strict settings
docker compose -f examples/docker-compose.lint.yml run --rm lint-strict

# Lint specific standards (Lua 5.1, 5.2, 5.3, etc.)
docker compose -f examples/docker-compose.lint.yml run --rm lint-lua53
```

#### CI/CD Integration (`examples/docker-compose.ci.yml`)
```bash
# Generate JUnit report for CI
docker compose -f examples/docker-compose.ci.yml run --rm ci-junit

# Generate JSON report
docker compose -f examples/docker-compose.ci.yml run --rm ci-json

# Check with exit code only
docker compose -f examples/docker-compose.ci.yml run --rm ci-check
```

### Environment Variables

The compose services support environment variables for customization:

- `LUACHECK_VERSION`: Specify Luacheck image version (default: latest)
- `LUACHECK_CONFIG`: Path to .luacheckrc file
- `LUACHECK_GLOBALS`: Comma-separated list of allowed globals
- See individual compose files for more options

### Tips

1. **Custom Commands**: Override the default command:
   ```bash
   docker compose run --rm luacheck --std lua53 --globals love .
   ```

2. **Configuration File**: Create a `.luacheckrc` file in your project root for persistent settings

3. **Persistent Settings**: The repository includes a `.env` file with default settings

## Configuration

Luacheck can be configured using a `.luacheckrc` file. Here's an example:

```lua
return {
    std = "lua53",
    globals = {
        "love",
        "game"
    },
    ignore = {
        "212", -- Unused argument
        "213", -- Unused loop variable
    },
    files = {
        ["tests/"] = {
            std = "+busted"
        }
    }
}
```

## Versioning

This project uses semantic versioning that matches the Docker image contents:

**Format:** `{luacheck_version}-alpine{alpine_version}-{build_number}`

Examples:
- `1.2.0-alpine3.22.1-1` - Luacheck 1.2.0 on Alpine 3.22.1, build 1
- `latest` - Most recent stable release

For detailed release process and versioning guidelines, see [RELEASE.md](RELEASE.md).

## Automated Dependency Updates

This project uses [Renovate](https://docs.renovatebot.com/) to automatically check for updates to:
- Alpine Linux base image version
- Luacheck version

Renovate runs weekly and creates pull requests when updates are available.

## Documentation

- [Development Guide](DEVELOPMENT.md) - Building, debugging, and contributing
- [Testing Guide](TEST.md) - Running and writing tests
- [Release Process](RELEASE.md) - Creating releases and versioning

## Links

- [Luacheck Documentation](https://luacheck.readthedocs.io/)
- [Alpine Linux](https://www.alpinelinux.org/)

# License

MIT License

Copyright (c) 2025 Michael Wiesendanger

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
