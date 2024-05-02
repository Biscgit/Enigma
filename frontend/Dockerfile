FROM debian:stable-slim AS builder

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
ENV PATH="${PATH}:/home/builder/flutter/bin"

# configure flutter
RUN git config --global --add safe.directory /home/builder/flutter
RUN flutter --disable-analytics

RUN flutter channel stable
RUN flutter upgrade

# copy and build
WORKDIR /home/builder/frontend
RUN flutter create --platforms web .
RUN flutter clean

COPY ./pubspec.yaml .
RUN flutter pub get
COPY . .
RUN flutter build web --release

# serve site with nginx
FROM nginx:1.25-alpine

# permission security
RUN addgroup -S sgroup && adduser -S webserver -G sgroup
WORKDIR /home/webserver

# copy files
COPY --from=builder /home/builder/frontend/build/web /home/webserver/enigma
COPY ./nginx.conf /etc/nginx/

# expose and run
EXPOSE 8080
