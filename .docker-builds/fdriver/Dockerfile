# by David Horvát, 2024
FROM registry.mygit.th-deg.de/ts19084/enigma/flutter-builder:dev-e2e

# install dependencies
RUN sudo apt install -y wget unzip xvfb libxi6 libgconf-2-4 nmap iputils-ping curl

# install chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    sudo apt install -y ./google-chrome-stable_current_amd64.deb && \
    google-chrome --version && \
    rm google-chrome-stable_current_amd64.deb
ENV PATH="$PATH:/usr/bin/google-chrome-stable"

# install chromedriver
RUN wget https://storage.googleapis.com/chrome-for-testing-public/125.0.6422.78/linux64/chromedriver-linux64.zip && \
    unzip chromedriver-linux64.zip && \
    sudo mv chromedriver-linux64/chromedriver /usr/bin/chromedriver && \
    rm chromedriver-linux64.zip
RUN sudo chown builder:builder /usr/bin/chromedriver && \
    sudo chmod +x /usr/bin/chromedriver

RUN sudo chmod +x /usr/bin/google-chrome-stable
ENV CHROME_EXECUTABLE=/usr/bin/google-chrome-stable

#RUN flutter config --enable-web
# sh -c 'chromedriver --port=4444 & flutter driver --target=test_driver/app.dart -d web-server --release  --web-browser-flag="--disable-gpu --headless"'
