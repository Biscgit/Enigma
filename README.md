# Enigma

[![pipeline status](https://mygit.th-deg.de/ts19084/enigma/badges/dev/pipeline.svg)](https://mygit.th-deg.de/ts19084/enigma/-/pipelines)
[![coverage report](https://mygit.th-deg.de/ts19084/enigma/badges/dev/coverage.svg)](https://mygit.th-deg.de/ts19084/enigma/-/commits/main)
[![Latest Release](https://mygit.th-deg.de/ts19084/enigma/-/badges/release.svg)](https://mygit.th-deg.de/ts19084/enigma/-/releases)

### Infos

- Website can be accessed on `http://localhost:8080` hosted with Nginx.
- Login for GitLab registry builds: `docker login registry.mygit.th-deg.de`
- Use a screen with resolution of at least 1920x1080 (zoom 100%) for best experience.

### Platforms

##### Linux

- Everything works out of the box

##### Windows

- Go to `frontend/flutter.env` and change `IP_FASTAPI=` to `localhost`

##### MacOS

- Ask Apple support

### Run Enigma

- `docker compose up`

### Run Enigma without GitLab

- `docker compose -f docker-compose.fullylocal.yml up --build` (Note: Fully local building can take a
  long time depending on Internet speed!)

### Run E2E Tests

- Launch chromedriver (chrome) or geckodriver (firefox) on `--port=4444`
- In `/frontend` run `flutter driver --target=test_driver/app.dart -d web-server --release`
- Append `--browser-name=firefox` to use an actually good browser (instead of Chrome) and increase performance by
  3x–3.5x.

### Other Commands

- **Run** GitLab: `docker compose up --build -d`
- **Run** Locally (for development): `docker compose -f docker-compose.local.yml up --build -d` (Note: Clean building
  takes **3 to 8 Minutes!**)
- **Stop** Compose: `docker compose down`
- **Stop** and purge all: `docker compose down --rmi all --volumes` (Removes **all containers** and **database storage!
  **)
- **Restart**
  clean: `docker compose -f docker-compose.local.yml down --rmi all --volumes && docker compose -f docker-compose.local.yml up --build -d`

### Flutter commands

go to `/frontend` directory

- **Run** Linter: `flutter analyze`
- **Run** Flutter (with hot reload, compose needs to run in addition!): `flutter run -d chrome`
- **Run** Flutter tests (visible, but not working with all because of
  Chrome): `flutter driver --target=test_driver/app.dart -d chrome --no-headless`
- **Run** Flutter tests (headless, simple): `flutter --target=test_driver/app.dart -d web-server --release`
- **Run** Flutter tests NEW (headless,
  pipeline): `flutter driver --target=test_driver/app.dart -d web-server --release --browser-name=firefox`
- **Run** Flutter tests OLD (headless,
  pipeline): `flutter driver --target=test_driver/app.dart -d web-server --release --web-browser-flag="--disable-gpu --headless --window-size=1920,1080 --disable-infobars --disable-dev-shm-usage"`
- **Start** Chrome driver (before tests): `chromedriver --port=4444`
- **Start** Firefox driver (before tests): `geckodriver --port=4444` [`&> driver.log`]

### Backend commands

go to `/backend` directory

- **Run** Backend unit/integration tests: `pytest --cov` (have all packages from `requirements.testing.txt` installed)
- **Run** Linter: `ruff check`
