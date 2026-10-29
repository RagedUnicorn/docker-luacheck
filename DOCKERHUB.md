# Luacheck Alpine Docker Image

![Docker Luacheck](https://raw.githubusercontent.com/RagedUnicorn/docker-luacheck/master/docs/docker_luacheck_banner.png)

A lightweight Luacheck build on Alpine Linux for fast and efficient Lua code linting and static analysis.

## Quick Start

```bash
# Pull latest version
docker pull ragedunicorn/luacheck:latest

# Or pull specific version
docker pull ragedunicorn/luacheck:1.2.0-alpine3.24.1-1

# Run Luacheck
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest script.lua
```

On Windows, use the PowerShell form - `${PWD}` **with braces** and the colon
inside the quotes (without braces PowerShell parses `$PWD:` as a
scope-qualified variable, as in `$env:PATH`, and rejects the argument):

```powershell
# Run Luacheck
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest script.lua
```

## Features

- 🚀 **Small footprint**: ~15MB runtime image
- 📦 **Luacheck 1.2.0**: Latest stable version installed via LuaRocks
- 🔍 **Comprehensive analysis**: Detects undefined globals, unused variables, unreachable code, and more
- 🏗️ **Multi-platform**: Supports linux/amd64 and linux/arm64
- ⚡ **Fast**: Pure Lua implementation with no external dependencies
- 🧵 **Parallel checking**: Bundled `lanes` package enables `luacheck -j N` for large codebases
- 🔒 **Runs as non-root**: Executes as `nobody` for security (required by `lanes`)

## Supported Standards

**Lua versions**: Lua 5.1, 5.2, 5.3, 5.4, LuaJIT  
**Frameworks**: LÖVE, Minetest, Playdate SDK, OpenResty  
**Formatters**: Default, Plain, TAP, JUnit, Visual Studio

## Usage Examples

### Lint entire project

```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest .
```

PowerShell:

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest .
```

### Check specific Lua version compatibility

```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest \
  --std lua53 src/
```

PowerShell:

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest `
  --std lua53 src/
```

### Ignore specific warnings

```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest \
  --no-unused --no-redefined .
```

PowerShell:

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest `
  --no-unused --no-redefined .
```

### Generate CI reports

```bash
# JUnit format for CI systems
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest \
  --formatter JUnit . > luacheck-report.xml

# TAP format
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest \
  --formatter TAP .
```

PowerShell:

```powershell
# JUnit format for CI systems
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest `
  --formatter JUnit . > luacheck-report.xml

# TAP format
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest `
  --formatter TAP .
```

The `>` redirect writes UTF-8 in PowerShell 7; Windows PowerShell 5.1 writes
UTF-16, so pipe through `Out-File -Encoding utf8` there instead.

### Use configuration file

```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest \
  --config .luacheckrc .
```

PowerShell:

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest `
  --config .luacheckrc .
```

### Parallel checking on large codebases

```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest -j 4 .
```

PowerShell:

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/luacheck:latest -j 4 .
```

Set `-j` to the number of CPU cores to use. Backed by the bundled `lanes` package.

## File Permissions

The container runs as `nobody` (uid 65534). Files mounted at `/workspace` must be readable by that uid — world-readable files (mode `644`, the typical default) work out of the box. If your files are more restrictive, run as your own user:

```bash
docker run --rm --user $(id -u):$(id -g) \
  -v $(pwd):/workspace:ro ragedunicorn/luacheck:latest .
```

On Windows hosts this is not needed: Docker Desktop bind mounts do not carry
Unix file ownership, so `nobody` can read mounted files without `--user` (and
`id` does not exist in PowerShell). A read-only mount works the same way -
keep the `:ro` suffix inside the quotes:

```powershell
docker run --rm -v "${PWD}:/workspace:ro" ragedunicorn/luacheck:latest .
```

Lanes must be configured by an unprivileged uid; passing `--user 0:0` (root) will cause `luacheck -j N` to fail. Any non-root uid works.

## Tags

This image uses semantic versioning that includes all component versions:

**Format:** `{luacheck_version}-alpine{alpine_version}-{build_number}`

### Version Examples

- `1.2.0-alpine3.24.1-1` - First build of Luacheck 1.2.0 on Alpine 3.24.1
- `1.2.0-alpine3.24.1-2` - Rebuild of same versions (bug fixes, optimizations)
- `1.2.0-alpine3.24.2-1` - Alpine Linux patch update
- `1.3.0-alpine3.24.1-1` - Luacheck version update

When updates are available through automated dependency management, new releases are created with appropriate version tags.

## Links

- **GitHub**: [https://github.com/RagedUnicorn/docker-luacheck](https://github.com/RagedUnicorn/docker-luacheck)
- **Issues**: [https://github.com/RagedUnicorn/docker-luacheck/issues](https://github.com/RagedUnicorn/docker-luacheck/issues)
- **Releases**: [https://github.com/RagedUnicorn/docker-luacheck/releases](https://github.com/RagedUnicorn/docker-luacheck/releases)

## License

MIT License - See [GitHub repository](https://github.com/RagedUnicorn/docker-luacheck) for details.
