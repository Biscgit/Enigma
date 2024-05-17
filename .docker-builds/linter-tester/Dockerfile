FROM registry.mygit.th-deg.de/ts19084/enigma/backend/rustlib:latest as builder
FROM python:3.12-alpine

RUN apk update && apk add libxml2 libxml2-utils openrc docker gcc

# setup venv
WORKDIR /app
RUN python -m venv venv
ENV PATH="/app/venv/bin:$PATH"

# install rustlib
COPY --from=builder /home/wheel/rustlib-0.1.0-cp312-cp312-linux_x86_64.whl ./packeges/
RUN python3 -m pip install --no-cache-dir ./packeges/*.whl && rm -r ./packeges

# install dependencies
COPY ./requirements.txt ./
RUN python3 -m pip install -r requirements.txt
