# by David Horvát, 2024
FROM python:3.12-alpine as builder

RUN apk update && apk add --no-cache curl gcc musl-dev
RUN curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs > rustup.sh && \
    chmod +x rustup.sh && \
    ./rustup.sh -y && \
    rm rustup.sh
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup default stable

# setup python
RUN python3 -m ensurepip
RUN python3 -m pip install --no-cache --upgrade pip setuptools maturin

# install rustlib
ENV PYO3_PYTHON=python3.12
WORKDIR /home/

COPY . .
RUN python3 -m maturin build --release -o wheel && cargo clean
