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
FROM nginx:1.25-alpine

# permission security
RUN addgroup -S sgroup && adduser -S webserver -G sgroup
WORKDIR /home/webserver

# copy files
COPY --from=builder /home/builder/frontend/build/web /home/webserver/enigma
COPY ./nginx.conf /etc/nginx/

# expose and run
EXPOSE 8080
