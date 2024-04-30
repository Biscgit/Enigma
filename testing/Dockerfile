FROM alpine:latest

RUN mkdir ~/trivy && cd ~/trivy && apk add wget && wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_0.50.4_Linux-64bit.tar.gz && tar -xf trivy_*_Linux-64bit.tar.gz && mv trivy /bin/. && apk add docker
