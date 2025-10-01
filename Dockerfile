FROM debian:latest
COPY ./ /root/basherpkg
WORKDIR /root/basherpkg

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install curl git -y

RUN curl -s https://raw.githubusercontent.com/basherpm/basher/master/install.sh | bash
ENV PATH="/root/.basher/bin:${PATH}"
RUN basher link . kucukkanat/pkg