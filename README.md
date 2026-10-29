# docker-luacheck

![](./docs/docker_luacheck_banner.svg)

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
- **Parallel checking**: Bundled `lanes` package enables `luacheck -j N` for large codebases
- **Runs as non-root**: Container executes as `nobody` (required by `lanes`, also a security best practice)

## Quick Start

```bash
# Pull the image
docker pull ragedunicorn/luacheck:latest

# Run Luacheck on a single file
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest myfile.lua

# Run Luacheck on a directory
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest .
```

On Windows, use the PowerShell form:

```powershell
# Run Luacheck on a single file
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest myfile.lua

# Run Luacheck on a directory
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest .
```

Write `${PWD}` **with braces** and keep the colon inside the quotes - without
braces PowerShell parses `$PWD:` as a scope-qualified variable (as in
`$env:PATH`) and rejects the argument. See the
[Windows (PowerShell) notes](#windows-powershell-notes) for details.

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
docker run -v $(pwd):/workspace ragedunicorn/luacheck:1.2.0-alpine3.24.1-1 [luacheck-options]
```

PowerShell:

```powershell
# Using latest version
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest [luacheck-options]

# Using specific Luacheck version (latest Alpine build)
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:1.2.0 [luacheck-options]

# Using exact version combination
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:1.2.0-alpine3.24.1-1 [luacheck-options]
```

### Examples

#### Check a Single File
```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest myfile.lua
```

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest myfile.lua
```

#### Check All Lua Files in Directory
```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest .
```

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest .
```

#### Check with Custom Configuration
```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest --config .luacheckrc .
```

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest --config .luacheckrc .
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

```powershell
# TAP format
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest --formatter TAP .

# JUnit XML format
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest --formatter JUnit .

# JSON format
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest --formatter json .
```

#### Ignore Specific Warnings
```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest . --ignore 212 213
```

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest . --ignore 212 213
```

#### Set Global Variables
```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest . --globals love game
```

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest . --globals love game
```

List the files before `--ignore` and `--globals`: these options take any number
of values, so a file name placed after them (such as the trailing `.`) is read
as another warning pattern or global name, and Luacheck stops with
`missing argument 'files'`.

#### Parallel Checking on Large Codebases
The image bundles the `lanes` package, so Luacheck's `-j` flag works out of the box:

```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest -j 4 .
```

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest -j 4 .
```

Set `-j` to the number of CPU cores you want to use. On large codebases this reduces wall-clock time roughly linearly with core count.

## File Permissions

The container runs as the unprivileged `nobody` user (uid 65534). This is required for `lanes` to start (Luacheck's parallel mode), and is also a security best practice.

Files mounted at `/workspace` must be readable by `nobody`. World-readable files (the typical default, mode `644`) work without further configuration. If your files have restrictive permissions and you see `Permission denied` errors, run the container as your own user instead:

```bash
docker run --rm --user $(id -u):$(id -g) -v $(pwd):/workspace:ro ragedunicorn/luacheck:latest .
```

Note: Lanes must be configured by an unprivileged uid, so passing `--user 0:0` (root) will cause `luacheck -j N` to fail. Any non-root uid works.

Writing needs the same care: `nobody` cannot create files in a bind mount owned by your user, nor in one Docker created as root because the host directory did not exist. Redirecting output on the host (`docker run ... > report.xml`) needs no extra setup. When the container itself writes into a mounted directory, create the directory first and run as your own user:

```bash
mkdir -p reports
docker run --rm --user $(id -u):$(id -g) \
  -v $(pwd):/workspace:ro -v $(pwd)/reports:/reports \
  --entrypoint /bin/sh ragedunicorn/luacheck:latest \
  -c "luacheck --formatter JUnit . > /reports/luacheck-junit.xml"
```

The report services in `examples/docker-compose.ci.yml` (`ci-junit`, `ci-plain`, `ci-tap`) already do this: they run as `${UID:-1000}:${GID:-1000}` and write into the tracked `examples/reports/` directory. If your ids are not `1000`, pass them explicitly:

```bash
UID=$(id -u) GID=$(id -g) docker compose -f examples/docker-compose.ci.yml run --rm ci-junit
```

**Windows hosts:** none of this applies. Docker Desktop bind mounts do not carry
Unix file ownership, so `nobody` can read and write mounted directories without
`--user` (and `id` does not exist in PowerShell). The compose report services
work with their default ids. To write a report from inside the container:

```powershell
New-Item -ItemType Directory -Force reports | Out-Null
docker run --rm `
  -v "${PWD}:/workspace:ro" -v "${PWD}/reports:/reports" `
  --entrypoint /bin/sh ragedunicorn/luacheck:latest `
  -c 'luacheck --formatter JUnit . > /reports/luacheck-junit.xml'
```

### Windows (PowerShell) notes

The PowerShell variants above differ from the bash ones in two ways: the
mount is written `-v "${PWD}:/workspace"` instead of `-v $(pwd):/workspace`,
and the backtick replaces `\` as the line-continuation character.

The mount spelling matters:

- Pasting the bash form into PowerShell breaks: PowerShell passes
  `$(pwd):/workspace` (quoted or not) to Docker as two arguments, `C:\path`
  and `:/workspace`, and Docker stops with `invalid reference format`.
- `"$PWD:/workspace"` without braces is a parse error: PowerShell reads a
  colon after a variable as a scope qualifier (as in `$env:PATH`), and `/` is
  not a valid variable-name character.
- `"${PWD}:/workspace"` works: the braces end the variable name at `PWD`, the
  colon stays literal, and Docker splits the resulting `C:\path:/workspace`
  on the second colon because it recognises the `C:` drive prefix.

Luacheck only reads `/workspace`, so the mount can be read-only. Add the `:ro`
suffix inside the quotes as well: `-v "${PWD}:/workspace:ro"`.

To check what the container actually sees under `/workspace`, run a
look-inside command:

```powershell
docker run --rm -v "${PWD}:/workspace:ro" --entrypoint sh ragedunicorn/luacheck:latest -c 'pwd; ls -la /workspace'
```

The single quotes keep `pwd; ls -la /workspace` as one literal argument to
the container's `sh`, so the `;` runs inside the container - unquoted,
PowerShell would treat `;` as its own statement separator and run
`ls -la /workspace` on the host. The same applies to the `>` in the report
example above: inside single quotes it redirects in the container, not on the
host.

Redirecting a report on the host (`docker run ... > luacheck-report.xml`)
writes UTF-8 in PowerShell 7. Windows PowerShell 5.1 writes UTF-16 instead,
which most CI tools reject as JUnit XML; there, pipe through
`Out-File -Encoding utf8` or write the report from inside the container.

For more complex invocations where PowerShell keeps mangling arguments, the
[stop-parsing token `--%`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parsing#the-stop-parsing-token)
is an escape hatch: PowerShell passes everything after it verbatim. Nothing
after `--%` is expanded - including `${PWD}` - so it cannot be combined with
the mount examples above; none of the examples in this README need it.

## Docker Compose Usage

This repository includes Docker Compose configurations for easier usage and common linting workflows.

### Basic Setup

1. Place your Lua files in your project directory

2. Run Luacheck using docker compose (the same command works in bash and PowerShell):
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

# Generate plain-text report
docker compose -f examples/docker-compose.ci.yml run --rm ci-plain

# Generate TAP report
docker compose -f examples/docker-compose.ci.yml run --rm ci-tap

# Check with exit code only
docker compose -f examples/docker-compose.ci.yml run --rm ci-check

# Check without self-reference warnings
docker compose -f examples/docker-compose.ci.yml run --rm ci-warnings-only
```

### Environment Variables

The compose services support environment variables for customization:

- `LUACHECK_VERSION`: Specify Luacheck image version (default: latest)
- Luacheck options such as the config file or allowed globals are not read from environment variables; pass them as arguments (`--config`, `--globals`) or set them in a `.luacheckrc` file

### Tips

1. **Custom Commands**: Override the default command:
   ```bash
   docker compose run --rm luacheck --std lua53 --globals love .
   ```

2. **Configuration File**: Create a `.luacheckrc` file in your project root for persistent settings

3. **Persistent Settings**: The repository includes a `.env` file with default settings. You can modify it to set your preferred versions:
   ```env
   LUACHECK_VERSION=1.2.0-alpine3.24.1-1
   ```

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
- `1.2.0-alpine3.24.1-1` - Luacheck 1.2.0 on Alpine 3.24.1, build 1
- `latest` - Most recent stable release

For detailed release process and versioning guidelines, see [RELEASE.md](RELEASE.md).

## Image Verification

Released images are signed with [cosign](https://docs.sigstore.dev/) keyless signing and carry SBOM and provenance attestations.

```bash
# Verify the signature (works for both ghcr.io/ragedunicorn/docker-luacheck and ragedunicorn/luacheck)
cosign verify ragedunicorn/luacheck:latest \
  --certificate-identity-regexp '^https://github.com/RagedUnicorn/docker-luacheck/\.github/workflows/docker_release\.yml@refs/tags/v' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com

# Inspect the SBOM and provenance attestations
docker buildx imagetools inspect ragedunicorn/luacheck:latest --format '{{ json .SBOM }}'
docker buildx imagetools inspect ragedunicorn/luacheck:latest --format '{{ json .Provenance }}'
```

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

Copyright (c) 2026 Michael Wiesendanger

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
