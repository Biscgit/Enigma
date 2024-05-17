# by David Horvát, 2024
FROM registry.mygit.th-deg.de/ts19084/enigma/backend/rustlib:cl-19 as builder
FROM python:3.12-alpine

# permission security
RUN addgroup -S sgroup && adduser -S fastapi -G sgroup
WORKDIR /home/fastapi

# install dependencies
# RUN apk update && apk add --no-cache gcc

COPY requirements.txt ./
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# install rustlib
COPY --from=builder /home/wheel/rustlib-0.1.0-cp312-cp312-linux_x86_64.whl ./packeges/
RUN python3 -m pip install --no-cache-dir ./packeges/*.whl && rm -r ./packeges

# copy files and run
USER fastapi
WORKDIR /home/fastapi
COPY ./server ./server

EXPOSE 8001
ENTRYPOINT ["uvicorn", "server.app:app", "--host", "0.0.0.0", "--port", "8001"]
