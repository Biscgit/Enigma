FROM alpine:latest

RUN apk update
RUN apk add wget docker

RUN mkdir ~/trivy
WORKDIR ~/trivy

RUN wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_0.50.4_Linux-64bit.tar.gz
RUN tar -xf trivy_*_Linux-64bit.tar.gz

RUN mv trivy /bin/.
