# Use Alpine Linux as base image for minimal container size
FROM alpine:latest

# Copy configuration file to toggle installations during build
COPY build.config /tmp/

# Run installation commands conditionally based on build.config
RUN set -e && \
  # Update package index and install essential tools
  apk update && apk upgrade && \
  apk add --no-cache ca-certificates curl bash && \
  # Source the configuration file to set variables
  . /tmp/build.config && \
  # Install system tools if enabled
  if [ "$INSTALL_SYSTEM" = "true" ]; then \
    apk add --no-cache vim tmux wget openssh && \
    # Generate SSH host keys for secure connections
    ssh-keygen -A && \
    # Set root password for SSH access
    echo "root:$ROOT_PASSWORD" | chpasswd && \
    # Enable root login via SSH
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config ; \
  fi && \
  # Install programming runtimes if enabled
  if [ "$INSTALL_RUNTIMES" = "true" ]; then \
    apk add --no-cache nodejs npm && \
    # Install Bun JavaScript runtime
    curl -fsSL https://bun.sh/install | bash && \
    # Install Deno JavaScript/TypeScript runtime
    curl -fsSL https://deno.land/install.sh | sh && \
    # Add Bun and Deno to PATH for login shells
    echo 'export PATH="$PATH:/root/.bun/bin:/root/.deno/bin"' >> /etc/profile ; \
  fi && \
  # Install CLI tools if enabled
  if [ "$INSTALL_CLIS" = "true" ]; then \
    # Ensure Node.js and npm are available for CLI installations
    if [ "$INSTALL_RUNTIMES" != "true" ]; then \
      apk add --no-cache nodejs npm ; \
    fi && \
    # Install build dependencies for native modules
    apk add --no-cache build-base python3 && \
    # Install VSCode server for web-based code editing (using pre-built binary)
    wget https://github.com/coder/code-server/releases/download/v4.104.2/code-server-4.104.2-linux-arm64.tar.gz && \
    tar -xzf code-server-4.104.2-linux-arm64.tar.gz && \
    mv code-server-4.104.2-linux-arm64 /usr/local/code-server && \
    ln -s /usr/local/code-server/bin/code-server /usr/local/bin/code-server && \
    rm code-server-4.104.2-linux-arm64.tar.gz && \
    # Install Claude CLI for AI assistance
    npm install -g @anthropic-ai/claude-code && \
    # Install GitHub Copilot CLI for code suggestions
    npm install -g @github/copilot && \
    # Install Opencode CLI for development tasks
    curl -fsSL https://opencode.ai/install | bash && \
    # Remove build dependencies to keep image slim
    apk del build-base python3 ; \
  fi && \
  # Remove package manager and clean up caches to minimize size
  apk del --no-cache apk-tools && \
   rm -rf /var/cache/apk/* /tmp/*

ENV PATH="$PATH:/root/.bun/bin:/root/.deno/bin"

# Expose ports for SSH access and code-server
EXPOSE 22 8080

# Start the SSH daemon to allow remote connections
CMD ["/usr/sbin/sshd", "-D"]