dka() {
    docker rm $(docker ps -aq) -f
}