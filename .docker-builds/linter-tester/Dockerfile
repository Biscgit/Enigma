FROM python:3.12-alpine

RUN apk update && apk add libxml2 libxml2-utils openrc docker

# setup venv
WORKDIR /app
RUN python -m venv venv
ENV PATH="/app/venv/bin:$PATH"

# install dependencies
COPY ./requirements.txt ./
RUN python3 -m pip install -r requirements.txt
