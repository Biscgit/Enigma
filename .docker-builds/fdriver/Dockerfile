# by David Horvát, 2024
FROM registry.mygit.th-deg.de/ts19084/enigma/flutter-builder:latest

# install dependencies
RUN sudo apt install -y wget jq

# install latest stable chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    sudo apt install -y ./google-chrome-stable_current_amd64.deb && \
    google-chrome --version && \
    rm google-chrome-stable_current_amd64.deb
ENV PATH="$PATH:/usr/bin/google-chrome-stable"

# install latest stable chromedriver
RUN chr_version=$(wget -q -O - https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions.json | jq -r '.channels.Stable.version') && \
    wget https://storage.googleapis.com/chrome-for-testing-public/${chr_version}/linux64/chromedriver-linux64.zip && \
    unzip chromedriver-linux64.zip && \
    sudo mv chromedriver-linux64/chromedriver /usr/bin/chromedriver && \
    rm chromedriver-linux64.zip
RUN sudo chown builder:builder /usr/bin/chromedriver && \
    sudo chmod +x /usr/bin/chromedriver

RUN sudo chmod +x /usr/bin/google-chrome-stable
ENV CHROME_EXECUTABLE=/usr/bin/google-chrome-stable

# sh -c 'chromedriver --port=4444 & flutter driver --target=test_driver/app.dart -d web-server --release  --web-browser-flag="--disable-gpu --headless"'
