# by David Horvát, 2024
FROM registry.mygit.th-deg.de/ts19084/enigma/flutter-builder:latest as builder

# setup
USER builder
WORKDIR /home/builder/frontend

# copy files and build
COPY ./pubspec.yaml .
RUN flutter pub get
COPY . .
RUN flutter build web --release

# serve site with nginx
FROM nginx:mainline-alpine-slim
RUN apk update && apk upgrade

# copy files
WORKDIR /home/webserver
COPY --from=builder /home/builder/frontend/build/web /home/webserver/enigma
COPY ./nginx.conf /etc/nginx/

# expose and run
EXPOSE 8080
