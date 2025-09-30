# Building the Ultimate Docker Developer Environment: Tricks and Techniques

As developers, we spend countless hours configuring our development environments. What if you could have a portable, consistent, and powerful development setup that works anywhere? In this post, I'll share how we built a comprehensive Docker developer environment that includes everything you need for modern development.

## The Vision

Our goal was to create a Docker container that:
- Runs a full development environment accessible via SSH
- Includes multiple JavaScript runtimes (Node.js via Bun, Deno)
- Has AI coding assistants pre-installed
- Provides VS Code through code-server
- Maintains proper user permissions and security

## The Dockerfile Breakdown

### Base Setup and User Management

```dockerfile
FROM debian:trixie
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y ca-certificates
RUN apt install -y curl wget unzip tmux vim git jq openssh-server sudo

# Create a user called kucukkanat with it's home directory and add to sudoers
RUN useradd -m -s /bin/bash kucukkanat && \
    echo "kucukkanat ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chsh -s /usr/bin/bash kucukkanat
```

**Key Tricks:**
- `DEBIAN_FRONTEND=noninteractive` prevents interactive prompts during package installation
- Creating a dedicated user instead of running as root improves security
- Adding the user to sudoers with `NOPASSWD` allows seamless package installation

### Homebrew Installation

```dockerfile
# Install homebrew
RUN mkdir -p /home/linuxbrew && chmod -R 777 /home/linuxbrew
USER kucukkanat
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
# Add homebrew paths to bashrc
RUN cat << "EOF" >> /home/kucukkanat/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
EOF
```

**Key Tricks:**
- Switch to the non-root user before installing Homebrew
- Create `/home/linuxbrew` directory with proper permissions
- Use a heredoc to append to `.bashrc` without complex escaping

### JavaScript Runtimes

```dockerfile
# Install Bun. We love Bun!
RUN curl -fsSL https://bun.sh/install | bash
# Ensure bun is in PATH because docker containers don't load .bashrc by default
ENV PATH="/home/kucukkanat/.bun/bin:${PATH}"

# Install Deno because why not? "-s -- -y" to skip the prompt
RUN curl -fsSL https://deno.land/install.sh | sh -s -- -y
```

**Key Tricks:**
- Bun is installed first and added to PATH via ENV (not just .bashrc)
- Deno installation uses `-s -- -y` to skip interactive prompts
- ENV PATH ensures tools are available even when .bashrc isn't sourced

### AI Coding Assistants

```dockerfile
# Install ai assistants from npm and brew
RUN bun install -g @anthropic-ai/claude-code opencode-ai @google/gemini-cli
```

**Key Tricks:**
- Use Bun for faster npm package installation
- Install multiple AI assistants for different use cases
- Global installation makes them available everywhere

### VS Code via Code-Server

```dockerfile
# Install code-server  (using method=standalone to avoid using root)
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone
RUN echo "" >> /home/kucukkanat/.bashrc
RUN echo "export PATH=\$PATH:/home/kucukkanat/.local/bin" >> /home/kucukkanat/.bashrc
# Default code-server password
ENV PASSWORD="code"
RUN mkdir -p /home/kucukkanat/.config/code-server
RUN cat << "EOF" >> /home/kucukkanat/.config/code-server/config.yaml
bind-addr: 0.0.0.0:8080
app-name: kullanat
EOF
```

**Key Tricks:**
- `--method=standalone` avoids permission issues
- Configure to bind to `0.0.0.0` for external access
- Set a default password via environment variable
- Custom app name for personalization

### SSH Server Setup

```dockerfile
# GO BACK TO ROOT USER
USER root

#region SSH SERVER STUFF
# Create startup script for SSH daemon
RUN cat << "EOF" > /usr/local/bin/start-ssh.sh
#!/bin/bash
SSH_PORT=2222
/usr/sbin/sshd -p $SSH_PORT -D
EOF
RUN chmod +x /usr/local/bin/start-ssh.sh

# Expose default SSH port
EXPOSE 7000

# Start SSH daemon
CMD ["/usr/local/bin/start-ssh.sh"]
#endregion
```

**Key Tricks:**
- Switch back to root for SSH server setup
- Use a startup script to configure SSH port dynamically
- Expose port 7000 (custom port) instead of default 22
- Run SSH daemon in foreground with `-D` flag

## Building and Running

### Build the Image
```bash
docker build -t devenv .
```

### Run the Container
```bash
docker run -d -p 7000:2222 -p 8080:8080 --name my-dev devenv
```

### Connect via SSH
```bash
ssh kucukkanat@localhost -p 7000
```

### Access VS Code
Open your browser and navigate to `http://localhost:8080`, password: `code`

## Advanced Tricks and Optimizations

### 1. Volume Mounting for Persistence
```bash
docker run -d \
  -p 7000:2222 \
  -p 8080:8080 \
  -v ~/projects:/home/kucukkanat/projects \
  -v ~/.ssh:/home/kucukkanat/.ssh \
  --name my-dev \
  devenv
```

### 2. Docker Compose for Easy Management
```yaml
version: '3.8'
services:
  devenv:
    build: .
    ports:
      - "7000:2222"
      - "8080:8080"
    volumes:
      - ./projects:/home/kucukkanat/projects
      - ~/.ssh:/home/kucukkanat/.ssh
    restart: unless-stopped
```

### 3. Custom SSH Key Setup
Add this to your Dockerfile for automatic SSH key setup:
```dockerfile
RUN mkdir -p /home/kucukkanat/.ssh && \
    chmod 700 /home/kucukkanat/.ssh && \
    touch /home/kucukkanat/.ssh/authorized_keys && \
    chmod 600 /home/kucukkanat/.ssh/authorized_keys
```

### 4. Environment-Specific Configurations
Use build arguments for customization:
```dockerfile
ARG USERNAME=kucukkanat
ARG PASSWORD=code
RUN useradd -m -s /bin/bash $USERNAME
ENV PASSWORD=$PASSWORD
```

## Security Considerations

1. **Change Default Passwords**: Always change the default code-server password
2. **SSH Key Authentication**: Use SSH keys instead of passwords when possible
3. **Network Isolation**: Consider using Docker networks to isolate containers
4. **Regular Updates**: Keep base images and packages updated

## Performance Tips

1. **Use .dockerignore**: Exclude unnecessary files from build context
2. **Layer Caching**: Order Dockerfile instructions from least to most frequently changing
3. **Multi-stage Builds**: Use multi-stage builds to reduce final image size
4. **Resource Limits**: Set memory and CPU limits in production

## Troubleshooting Common Issues

### SSH Connection Refused
- Check if the SSH port is correctly mapped
- Verify the SSH daemon is running inside the container
- Check firewall settings

### Code-Server Not Accessible
- Ensure port 8080 is mapped correctly
- Check if code-server is running: `ps aux | grep code-server`
- Verify the configuration file syntax

### Permission Issues
- Always switch to the correct user before running commands
- Use `sudo` when necessary (configured without password)
- Check file ownership in mounted volumes

## Extending the Environment

### Adding More Tools
```dockerfile
# Install additional development tools
RUN apt install -y htop tree ripgrep fzf
RUN brew install neovim lazygit
```

### Database Services
Extend with Docker Compose to add databases:
```yaml
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: devpass
    ports:
      - "5432:5432"
  
  redis:
    image: redis:7
    ports:
      - "6379:6379"
```

## Conclusion

This Docker developer environment provides a comprehensive, portable, and consistent development setup. By leveraging Docker's containerization, we can ensure that our development environment works the same way everywhere, from local machines to cloud servers.

The key to success is understanding the interplay between Docker layers, user permissions, and service configuration. With these techniques, you can create powerful development environments that scale with your needs.

What tools and configurations would you add to make this environment even better? Share your thoughts and experiences in the comments!

---

*This Docker environment demonstrates how modern development can be both powerful and portable. Whether you're working on a laptop or deploying to the cloud, having a consistent environment eliminates the "it works on my machine" problem once and for all.*