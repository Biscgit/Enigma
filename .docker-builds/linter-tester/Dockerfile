FROM python:3.12-alpine

RUN apk update && apk add -y libxml2 libxml2-utils openrc docker

RUN python3 -m ensurepip
RUN python3 -m pip install --no-cache --upgrade pip setuptools

# install testing requiremenets
COPY ./requirements.txt ./
RUN python3 -m pip install --no-cache-dir -r requirements.txt
