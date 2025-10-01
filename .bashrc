export LANG=C.UTF-8
export LC_ALL=C.UTF-8


dka() {
    docker rm $(docker ps -aq) -f
}

# Claude config
export ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic
# Get that from https://z.ai/manage-apikey/apikey-list
export ANTHROPIC_AUTH_TOKEN=xxxxxx
export ANTHROPIC_MODEL="glm-4.5"

# Add bun to path
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"