# Luacheck Alpine Docker Image

![Docker Luacheck](https://raw.githubusercontent.com/RagedUnicorn/docker-luacheck/master/docs/docker_luacheck.png)

A lightweight Luacheck build on Alpine Linux for fast and efficient Lua code linting and static analysis.

## Quick Start

```bash
# Pull latest version
docker pull ragedunicorn/luacheck:latest

# Or pull specific version
docker pull ragedunicorn/luacheck:1.2.0-alpine3.22.1-1

# Run Luacheck
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest script.lua
```

## Features

- 🚀 **Small footprint**: ~15MB runtime image
- 📦 **Luacheck 1.2.0**: Latest stable version installed via LuaRocks
- 🔍 **Comprehensive analysis**: Detects undefined globals, unused variables, unreachable code, and more
- 🏗️ **Multi-platform**: Supports linux/amd64 and linux/arm64
- ⚡ **Fast**: Pure Lua implementation with no external dependencies

## Supported Standards

**Lua versions**: Lua 5.1, 5.2, 5.3, 5.4, LuaJIT  
**Frameworks**: LÖVE, Minetest, Playdate SDK, OpenResty  
**Formatters**: Default, Plain, TAP, JUnit, Visual Studio

## Usage Examples

### Lint entire project

```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest .
```

### Check specific Lua version compatibility

```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest \
  --std lua53 src/
```

### Ignore specific warnings

```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest \
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

### Use configuration file

```bash
docker run -v $(pwd):/workspace ragedunicorn/luacheck:latest \
  --config .luacheckrc .
```

## Tags

This image uses semantic versioning that includes all component versions:

**Format:** `{luacheck_version}-alpine{alpine_version}-{build_number}`

### Version Examples

- `1.2.0-alpine3.22.1-1` - Initial release with Luacheck 1.2.0 and Alpine 3.22.1
- `1.2.0-alpine3.22.1-2` - Rebuild of same versions (bug fixes, optimizations)
- `1.2.0-alpine3.22.2-1` - Alpine Linux patch update
- `1.3.0-alpine3.22.1-1` - Luacheck version update

When updates are available through automated dependency management, new releases are created with appropriate version tags.

## Links

- **GitHub**: [https://github.com/RagedUnicorn/docker-luacheck](https://github.com/RagedUnicorn/docker-luacheck)
- **Issues**: [https://github.com/RagedUnicorn/docker-luacheck/issues](https://github.com/RagedUnicorn/docker-luacheck/issues)
- **Releases**: [https://github.com/RagedUnicorn/docker-luacheck/releases](https://github.com/RagedUnicorn/docker-luacheck/releases)

## License

MIT License - See [GitHub repository](https://github.com/RagedUnicorn/docker-luacheck) for details.
