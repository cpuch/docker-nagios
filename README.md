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

### Using Pre-built Image

```bash
docker run -d \
    --name nagios \
    -p 8080:80 \
    -p 5667:5667 \
    cpuchalver/nagios:latest
```

### Access Web Interface

- **URL**: http://localhost:8080
- **Default Username**: `nagiosadmin`
- **Default Password**: `nagios`

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

Install test  dependencies (Ubuntu/Debian)

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