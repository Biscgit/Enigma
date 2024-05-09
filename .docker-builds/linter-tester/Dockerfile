FROM archlinux:base-devel

RUN pacman-key --init
RUN pacman -Syu --noconfirm libxml2 docker python python-pip

# setup venv
WORKDIR /app
RUN python -m venv venv
ENV PATH="/app/venv/bin:$PATH"

# install dependencies
COPY ./requirements.txt ./
RUN python3 -m pip install -r requirements.txt
