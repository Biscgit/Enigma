FROM alpine:latest

RUN apk update && apk add --no-cache wget docker jq

RUN mkdir ~/trivy
WORKDIR ~/trivy

# get version file
RUN wget -q -O bom.json "https://github.com/aquasecurity/trivy/releases/latest/download/bom.json"

# read file and extrat version for download
RUN trivy_version=$(cat bom.json | jq -M '.metadata.component.version') &&  \
    echo "Current version: $trivy_version" && \
    wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_${trivy_version:2:-1}_Linux-64bit.tar.gz

RUN tar -xf trivy_*_Linux-64bit.tar.gz

RUN mv trivy /bin/.
WORKDIR /
