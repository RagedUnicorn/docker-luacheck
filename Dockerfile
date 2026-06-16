############################################
# Luacheck build stage
############################################
FROM alpine:3.24.0 AS build

# renovate: datasource=github-releases depName=lunarmodules/luacheck
ARG LUACHECK_VERSION=1.2.0
ARG PREFIX=/opt/luacheck

# Build stage labels
LABEL org.opencontainers.image.authors="Michael Wiesendanger <michael.wiesendanger@gmail.com>" \
      org.opencontainers.image.source="https://github.com/RagedUnicorn/docker-luacheck" \
      org.opencontainers.image.licenses="MIT"

# Install build dependencies
RUN apk add --no-cache --update \
    build-base \
    curl \
    git \
    lua5.3 \
    lua5.3-dev \
    luarocks5.3

WORKDIR /tmp/build

RUN luarocks-5.3 install luacheck ${LUACHECK_VERSION}

# Install lanes to enable luacheck's parallel `-j N` mode
RUN luarocks-5.3 install lanes

############################################
# Runtime stage
############################################
FROM alpine:3.24.0

ARG BUILD_DATE
ARG VERSION

# OCI-compliant labels
LABEL org.opencontainers.image.title="Luacheck on Alpine Linux" \
      org.opencontainers.image.description="Lightweight Luacheck Docker image built on Alpine Linux for Lua code linting" \
      org.opencontainers.image.vendor="ragedunicorn" \
      org.opencontainers.image.authors="Michael Wiesendanger <michael.wiesendanger@gmail.com>" \
      org.opencontainers.image.source="https://github.com/RagedUnicorn/docker-luacheck" \
      org.opencontainers.image.documentation="https://github.com/RagedUnicorn/docker-luacheck/blob/master/README.md" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.base.name="docker.io/library/alpine:3.24.0"

# Install runtime dependencies only
RUN apk add --no-cache --update \
    lua5.3

# Copy luacheck and all dependencies from build stage
COPY --from=build /usr/local /usr/local

WORKDIR /workspace

# Run as non-root. Lanes (used by luacheck `-j N`) only attempts
# privileged SCHED_RR scheduling when geteuid() == 0, and Docker's default
# sandbox denies that with EPERM. Running unprivileged keeps lanes on the
# default scheduler, which works in any container.
USER nobody

# Set the entrypoint to luacheck binary
ENTRYPOINT ["luacheck"]

# Default to showing help if no arguments provided
CMD ["--help"]
