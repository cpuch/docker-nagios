# Docker Nagios

A production-ready Nagios monitoring solution packaged in Docker with NRPE and NSCA support.

## 📊 Components

|Product | Version |
|------- | ------- |
| Nagios Core | 4.5.9 |
| Nagios Plugins | 2.4.12 |
| NRPE | 4.1.3 |
| NSCA | 2.10.3 |

## 🚀 Quick Start

### Docker Run

```bash
docker run -d \
    --name nagios \
    -p 8080:80 \
    -p 5667:5667 \
    cpuchalver/nagios:latest
```

### Docker Compose

```yaml
services:
  nagios:
    image: cpuchalver/nagios:latest
    ports:
      - "8080:80"
      - "5667:5667"
```

### Access Web Interface

- **URL**: http://localhost:8080
- **Default Username**: `nagiosadmin`
- **Default Password**: `nagios`

## 💾 Persistent Data

To persist Nagios data across container restarts, mount the following volumes:

### Important Directories

| Directory | Purpose | Recommended Mount |
|-----------|---------|-------------------|
| `/opt/nagios/var` | Logs, status files, retention data | `nagios_var:/opt/nagios/var` |
| `/opt/nagios/etc` | Configuration files | `nagios_etc:/opt/nagios/etc` |
| `/opt/nagios/libexec` | Custom plugins | `nagios_libexec:/opt/nagios/libexec` |

### Docker Run with Persistence

```bash
docker run -d \
    --name nagios \
    -p 8080:80 \
    -p 5667:5667 \
    -v nagios_var:/opt/nagios/var \
    -v nagios_etc:/opt/nagios/etc \
    -v nagios_libexec:/opt/nagios/libexec \
    cpuchalver/nagios:latest
```

### Docker Compose with Persistence

```yaml
services:
  nagios:
    image: cpuchalver/nagios:latest
    ports:
      - "8080:80"
      - "5667:5667"
    volumes:
      - nagios_var:/opt/nagios/var
      - nagios_etc:/opt/nagios/etc
      - nagios_libexec:/opt/nagios/libexec

volumes:
  nagios_var:
  nagios_etc:
  nagios_libexec:
```

**⚠️ Note**: Without persistent volumes, all configuration changes and historical data will be lost when the container is removed.

## 🪛 Build from source

### Clone the repository

```bash
git clone https://github.com/cpuch/docker-nagios
cd docker-nagios
```

### Setup environment

```bash
cp .env.example .env
```

**⚠️ Make sure to edit .env with your credentials in production!**

### Build image

```bash
# Default build
./scripts/run_build.sh

# Custom tag
./scripts/run_build.sh --set default.tags=myregistry/nagios:latest
```

### Start container

```bash
docker run -d \
  --name nagios \
  -p 80:80 \
  -p 5667:5667 \
  -v nagios_var:/opt/nagios/var \
  myregistry/nagios:latest
```

## 🧪 Testing

Install test dependencies (Ubuntu/Debian)

```bash
sudo apt install bats bats-assert bats-support
```

Run the comprehensive test suite:

```bash
./scripts/run_tests.sh
```

## ⚙️ Usage

### Check Nagios configuration

```bash
docker exec nagios bin/nagios -v etc/nagios.cfg
```

### Restart Nagios service

```bash
docker exec nagios supervisorctl -c /etc/supervisor/conf.d/supervisord.conf restart nagios
```

## 🔗 Links

- [GitHub Repository](https://github.com/cpuch/docker-nagios)
- [Docker Hub](https://hub.docker.com/r/cpuchalver/nagios)
- [Nagios Documentation](https://nagios.org/documentation/)
- [NRPE Documentation](https://github.com/NagiosEnterprises/nrpe)

## 📄 License

This project is licensed under the MIT License.