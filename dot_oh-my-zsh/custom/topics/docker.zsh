# =============================================================================
# Docker Configuration
# Topic: docker.zsh
# =============================================================================

# -----------------------------------------------------------------------------
# Docker Aliases
# -----------------------------------------------------------------------------
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dstop='docker stop'
alias drm='docker rm'
alias drmi='docker rmi'

# Docker Compose
alias dcu='docker-compose up'
alias dcud='docker-compose up -d'
alias dcd='docker-compose down'
alias dcl='docker-compose logs -f'
alias dcb='docker-compose build'
alias dcr='docker-compose restart'

# Docker system
alias dprune='docker system prune -af'
alias dvprune='docker volume prune -f'

# -----------------------------------------------------------------------------
# Docker Functions
# -----------------------------------------------------------------------------

# Stop all running containers
dstopall() {
    docker stop $(docker ps -q) 2>/dev/null
    echo "Stopped all running containers"
}

# Remove all stopped containers
drmall() {
    docker rm $(docker ps -aq) 2>/dev/null
    echo "Removed all stopped containers"
}

# Remove all images
drmiall() {
    docker rmi $(docker images -q) 2>/dev/null
    echo "Removed all images"
}

# Execute bash in a container
dbash() {
    if [ -z "$1" ]; then
        echo "Usage: dbash <container>"
        return 1
    fi
    docker exec -it "$1" /bin/bash 2>/dev/null || docker exec -it "$1" /bin/sh
}

# Show container resource usage
dstats() {
    docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}
