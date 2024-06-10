# Enigma

[![pipeline status](https://mygit.th-deg.de/ts19084/enigma/badges/dev/pipeline.svg)](https://mygit.th-deg.de/ts19084/enigma/-/pipelines)
[![coverage report](https://mygit.th-deg.de/ts19084/enigma/badges/dev/coverage.svg)](https://mygit.th-deg.de/ts19084/enigma/-/commits/main)
[![Latest Release](https://mygit.th-deg.de/ts19084/enigma/-/badges/release.svg)](https://mygit.th-deg.de/ts19084/enigma/-/releases)

### Infos

- Website can be accessed on `http://localhost:8080` hosted with nginx.
- Login for GitLab registry builds: `docker login registry.mygit.th-deg.de`

### Flutter commands

go to `/frontend` directory

- **Run** Linter: `flutter analyze`
- **Run** Flutter (with hot reload, compose needs to run in addition!): `flutter run -d chrome`
- **Run** Flutter tests (visible): `flutter driver --target=test_driver/app.dart -d chrome --no-headless`
- **Run** Flutter tests (headless): 
- `flutter driver --target=test_driver/app.dart -d web-server --release --web-browser-flag="--disable-gpu --headless"`
- **Start** Chrome driver (before tests): `chromedriver --port=4444`

### Backend commands

go to `/backend` directory

- **Run** Backend tests: `pytest --cov`
- **Run** Linter: `ruff check`

### Project Commands

- **Run** GitLab: `docker compose up --build -d`
- **Run** Locally: `docker compose -f docker-compose.local.yml up --build -d` (Note: Clean building takes **3 to 8
  Minutes!**)
- **Stop** Compose: `docker compose down`
- **Stop** and purge all: `docker compose down --rmi all --volumes` (Removes **all containers** and **database storage!
  **)