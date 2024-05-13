# by David Horvát, 2024
FROM python:3.12-alpine

# permission security
RUN addgroup -S sgroup && adduser -S fastapi -G sgroup
WORKDIR /home/fastapi

# setup python
RUN python3 -m ensurepip
RUN python3 -m pip install --no-cache --upgrade pip setuptools

# install dependencies
COPY requirements.txt ./
RUN python3 -m pip install --no-cache-dir -r requirements.txt
COPY . .

# run service with uvicorn
USER fastapi

EXPOSE 8001
ENTRYPOINT ["uvicorn", "server.app:app", "--host", "0.0.0.0", "--port", "8001"]
