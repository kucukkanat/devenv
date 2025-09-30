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

USER kucukkanat
# Install starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y
RUN echo "$(starship init bash)" >> /home/kucukkanat/.bashrc
# Install Bun. We love Bun!
RUN curl -fsSL https://bun.sh/install | bash
# Ensure bun is in PATH because docker containers don't load .bashrc by default
ENV PATH="/home/kucukkanat/.bun/bin:${PATH}"

# Install Deno because why not? "-s -- -y" to skip the prompt
RUN curl -fsSL https://deno.land/install.sh | sh -s -- -y
ENV PATH="/home/kucukkanat/.deno/bin:${PATH}"

# Install ai assistants from npm
ENV ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic
# Get that from https://z.ai/manage-apikey/apikey-list
ENV ANTHROPIC_AUTH_TOKEN=xxxxxx
ENV ANTHROPIC_MODEL="glm-4.5"
RUN bun i -g @anthropic-ai/claude-code
RUN bun i -g @google/gemini-cli
RUN bun i -g opencode-ai

# Install code-server  (using method standalone to avoid using root)
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone
ENV PATH="${PATH}:/home/kucukkanat/.local/bin"

# Default code-server password
ENV PASSWORD="code"
RUN mkdir -p /home/kucukkanat/.config/code-server
RUN cat << "EOF" >> /home/kucukkanat/.config/code-server/config.yaml
bind-addr: 0.0.0.0:8080
app-name: kullanat
EOF

# Create startup script for SSH daemon
RUN cat << "EOF" > /home/kucukkanat/start-ssh.sh
#!/bin/bash
SSH_PORT=2222
/usr/sbin/sshd -p $SSH_PORT -D
EOF
RUN chmod +x /home/kucukkanat/start-ssh.sh

# Install homebrew and some cool stuff 
USER root
RUN mkdir -p /home/linuxbrew && chmod -R 777 /home/linuxbrew
USER kucukkanat
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
# Add homebrew paths to bashrc and set PATH for subsequent RUN commands
RUN cat << "EOF" >> /home/kucukkanat/.bashrc

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
EOF
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
RUN if [ "$(uname -m)" = "x86_64" ]; then brew install gum mods; fi

# Expose default SSH port
EXPOSE 2222
# GO BACK TO ROOT USER
USER root
# Start SSH daemon
CMD ["/home/kucukkanat/start-ssh.sh"]
