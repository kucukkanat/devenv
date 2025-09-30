# Slim Docker Container

This Dockerfile creates a minimal Alpine Linux-based container with optional development tools, runtimes, and CLIs. It's designed to be as small as possible by using conditional installations and cleanup.

## What's Installed

The container conditionally installs packages based on `build.config`:

- **System Tools** (if `INSTALL_SYSTEM=true`): vim, tmux, wget, OpenSSH server. SSH is configured for root login with the password from `ROOT_PASSWORD`.
- **Runtimes** (if `INSTALL_RUNTIMES=true`): Node.js (with npm), Bun, Deno.
- **CLIs** (if `INSTALL_CLIS=true`): VSCode server (code-server), Claude CLI, GitHub Copilot CLI, Opencode CLI. Note: No official Gemini CLI exists, so it's omitted.

## Building the Container

1. Edit `build.config` to toggle installations (set variables to `true` or `false`).
2. Run `docker build .` to build the image.

## Running the Container

- Run `docker run -d -p 22:22 -p 8080:8080 <image_id>` to start the container.
- SSH in with `ssh root@localhost` (password from `build.config`).
- Code-server (if installed) is accessible at `http://localhost:8080`.

## Exposed Ports

- 22: SSH
- 8080: Code-server

## Customization

Modify `build.config` to enable/disable components and set the root password. Rebuild after changes.