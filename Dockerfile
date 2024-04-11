FROM python:3.12-alpine

ENTRYPOINT ["ping", "-c", "1", "google.com"]