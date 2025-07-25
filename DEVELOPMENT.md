# Development Guide

This document provides information for developers working on the Luacheck Docker image.

## Development Environment

### Prerequisites

- Docker installed and running
- Docker Compose installed
- Git for version control
- Text editor or IDE

### Project Structure

```
docker-luacheck/
├── Dockerfile              # Main image definition
├── docker-compose.yml      # Basic usage configuration
├── docker-compose.dev.yml  # Development environment
├── docker-compose.test.yml # Test orchestration
├── .env                    # Default environment variables
├── examples/               # Example Docker Compose configurations
│   ├── docker-compose.lint.yml
│   ├── docker-compose.ci.yml
│   ├── sample.lua
│   └── test.lua
├── test/                   # Container Structure Tests
│   ├── luacheck_test.yml
│   ├── luacheck_command_test.yml
│   └── luacheck_metadata_test.yml
└── docs/                   # Documentation assets
```

## Development Workflow

### 1. Local Development Mode

The `docker-compose.dev.yml` file provides an interactive development environment:

```bash
# Build the image locally
docker compose -f docker-compose.dev.yml build

# Run in development mode (interactive shell)
docker compose -f docker-compose.dev.yml run --rm luacheck-dev

# Inside the container, you can run luacheck manually
luacheck --version
luacheck --help
luacheck /examples/sample.lua
```

The development mode:

- Overrides the entrypoint to `/bin/sh` for interactive access
- Mounts the `./examples` directory for testing files
- Sets a custom prompt to identify the development environment
- Keeps STDIN open and allocates a TTY

### 2. Building the Image

```bash
# Basic build
docker build -t ragedunicorn/luacheck:dev .

# Build with specific versions
docker build \
  --build-arg LUACHECK_VERSION=1.2.0 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VERSION=1.2.0-alpine3.22.1-1 \
  -t ragedunicorn/luacheck:1.2.0-alpine3.22.1-1 .

# Multi-platform build (requires buildx)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ragedunicorn/luacheck:dev .
```

### 3. Testing Your Changes

After making changes, always build and test locally:

```bash
# Build your changes locally
docker build -t ragedunicorn/luacheck:test .

# Run all tests against your local build
LUACHECK_VERSION=test docker compose -f docker-compose.test.yml run test-all

# Run specific tests during development
LUACHECK_VERSION=test docker compose -f docker-compose.test.yml up container-test-command
```

**Important:** Never test against remote images - they may have different labels or configurations due to CI/CD overrides.

See [TEST.md](TEST.md) for detailed testing information.

## Making Changes

### Version Updates

This project uses [Renovate](https://docs.renovatebot.com/) to automatically manage dependency updates:

- **Luacheck**: Renovate monitors LuaRocks and creates PRs for new versions
- **Alpine Linux**: Renovate monitors Docker Hub and creates PRs for new Alpine versions

When Renovate creates a PR:

1. Review the changes in the PR
2. Check the CI/CD pipeline passes all tests
3. Test the build locally if it's a major version update
4. Merge the PR if everything looks good

Manual version updates are rarely needed, but if required:

```dockerfile
# Luacheck version
ARG LUACHECK_VERSION=1.2.0

# Alpine base image
FROM alpine:3.22.1
```

When manually updating versions:

1. Update the `FROM alpine:X.X.X` lines in the Dockerfile (both build and runtime stages)
2. Update `ARG LUACHECK_VERSION=X.X.X` in the Dockerfile
3. Test the build thoroughly
4. Update version numbers in documentation
5. Run the full test suite

### Adding New Features

1. Update the Dockerfile if needed
2. Update README.md to document the feature
3. Add tests to verify the feature works:
   - Add command test in `test/luacheck_command_test.yml`
   - Add file test in `test/luacheck_test.yml` if applicable
4. Test the build locally
5. Update examples if the feature enables new use cases

Example of adding a new formatter test:

```yaml
# In test/luacheck_command_test.yml
- name: 'Test custom formatter'
  command: 'luacheck'
  args: ['--formatter', 'custom', '/tmp/test.lua']
  setup: [
    ['sh', '-c', 'echo "print(\"test\")" > /tmp/test.lua']
  ]
  expectedOutput:
    - 'expected output pattern'
  exitCode: 0
```

## Code Style and Best Practices

### Dockerfile Best Practices

1. **Multi-stage builds**: Keep the build stage separate from runtime
2. **Layer optimization**: Group related commands to minimize layers
3. **Cache efficiency**: Order commands from least to most frequently changed
4. **Security**: Don't include build tools in the final image
5. **Labels**: Follow OCI naming conventions

### Documentation

1. **README.md**: Keep focused on user-facing information
2. **Comments**: Add comments in Dockerfile for complex operations
3. **Examples**: Provide working examples for new features
4. **Commit messages**: Use conventional format (feat:, fix:, docs:, etc.)

### Testing

1. **Test everything**: New features must include tests
2. **Test edge cases**: Include negative tests where appropriate
3. **Keep tests fast**: Avoid long-running operations in tests
4. **Test organization**: Group related tests together

## Debugging

### Common Issues

**Build failures:**

```bash
# Verbose build output
docker build --progress=plain --no-cache -t ragedunicorn/luacheck:debug .

# Check specific build stage
docker build --target build -t luacheck-build-stage .
```

**Luacheck not found:**

```bash
# Check installation paths
docker run --rm --entrypoint sh ragedunicorn/luacheck:dev -c "which luacheck"
docker run --rm --entrypoint sh ragedunicorn/luacheck:dev -c "ls -la /usr/local/bin/"
```

**Lua module issues:**

```bash
# Check Lua paths
docker run --rm --entrypoint sh ragedunicorn/luacheck:dev -c "lua5.3 -e 'print(package.path)'"
docker run --rm --entrypoint sh ragedunicorn/luacheck:dev -c "lua5.3 -e 'print(package.cpath)'"

# List installed modules
docker run --rm --entrypoint sh ragedunicorn/luacheck:dev -c "find /usr/local -name '*.lua' | sort"
```

**Permission issues:**

```bash
# Check user and permissions
docker run --rm --entrypoint sh ragedunicorn/luacheck:dev -c "id"
docker run --rm --entrypoint sh ragedunicorn/luacheck:dev -c "ls -la /workspace"
```

## Contributing

### Before Submitting Changes

1. Run the full test suite
2. Update documentation if needed
3. Add tests for new features
4. Ensure your code follows the existing style
5. Write clear commit messages

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes using conventional commits
4. Push to your fork
5. Open a Pull Request with a clear description

### Release Process

See [RELEASE.md](RELEASE.md) for information about creating releases.
