# Multi-stage build to copy binaries from other images

FROM debian:trixie
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y ca-certificates
RUN apt install -y curl wget unzip tmux vim git jq openssh-server sudo

# Create a user called kucukkanat with it's home directory and add to sudoers
RUN useradd -m -s /bin/bash kucukkanat && \
    echo "kucukkanat ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chsh -s /usr/bin/bash kucukkanat
# Permissions for linuxbrew installation

# Install homebrew
RUN mkdir -p /home/linuxbrew && chmod -R 777 /home/linuxbrew
USER kucukkanat
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
# Add homebrew paths to bashrc
RUN cat << "EOF" >> /home/kucukkanat/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
EOF

# Install Bun. We love Bun!
RUN curl -fsSL https://bun.sh/install | bash
# Ensure bun is in PATH because docker containers don't load .bashrc by default
ENV PATH="/home/kucukkanat/.bun/bin:${PATH}"

# Install Deno because why not? "-s -- -y" to skip the prompt
RUN curl -fsSL https://deno.land/install.sh | sh -s -- -y

# Install ai assistants from npm and brew
RUN bun install -g @anthropic-ai/claude-code opencode-ai @google/gemini-cli

# Install code-server  (using method standalone to avoid using root)
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

# Create startup script for SSH daemon
RUN cat << "EOF" > /usr/local/bin/start-ssh.sh
#!/bin/bash
SSH_PORT=2222
/usr/sbin/sshd -p $SSH_PORT -D
EOF
RUN chmod +x /usr/local/bin/start-ssh.sh

# Expose default SSH port
EXPOSE 2222
# GO BACK TO ROOT USER
USER root
# Start SSH daemon
CMD ["/usr/local/bin/start-ssh.sh"]
