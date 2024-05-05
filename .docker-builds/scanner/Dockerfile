FROM alpine:latest

RUN apk update
RUN apk add wget docker curl

RUN mkdir ~/trivy
WORKDIR ~/trivy

RUN export release_url=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/aquasecurity/trivy/releases/latest) && \
	export release_tag=$(basename $release_url | cut -b2-) && echo "export release_tag=$release_tag" >> /etc/environment && \
	wget https://github.com/aquasecurity/trivy/releases/download/v${release_tag}/trivy_${release_tag}_Linux-64bit.tar.gz && \
	tar -xf trivy_${release_tag}_Linux-64bit.tar.gz

RUN mv trivy /bin/.
WORKDIR /
