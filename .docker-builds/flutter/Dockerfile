FROM debian:stable-slim

# install dependencies
RUN apt update
RUN apt install -y curl file git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev

# permissions & security
RUN useradd -ms /bin/bash builder
USER builder
WORKDIR /home/builder

# install flutter
RUN curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.6-stable.tar.xz
RUN tar xvf flutter_linux_*-stable.tar.xz --directory=/home/builder/
RUN rm flutter_linux_*-stable.tar.xz
ENV PATH="${PATH}:/home/builder/flutter/bin"

# configure flutter
RUN git config --global --add safe.directory /home/builder/flutter
RUN flutter --disable-analytics && flutter config --no-cli-animations
RUN flutter channel stable && flutter upgrade

# generate build folder
WORKDIR /home/builder/frontend
RUN flutter create --platforms web .
RUN flutter clean
