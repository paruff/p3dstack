# Production Deployment Guide

## Production-Ready Features

All services in the P3DStack are now configured with production-ready features:

### ✅ Health Checks
Every service includes health check configurations:
- **Interval**: 30s (10s for databases)
- **Timeout**: 10s (5s for databases)
- **Retries**: 3-5 attempts
- **Start Period**: Varies by service complexity (10s-90s)

### ✅ Restart Policies
All services use `restart: unless-stopped` to ensure:
- Automatic recovery from crashes
- Persistence across host reboots
- Manual control when needed

### ✅ Resource Limits
Each service has CPU and memory limits:
- **Limits**: Maximum resources a service can use
- **Reservations**: Guaranteed minimum resources

### ✅ Container Names
All services have explicit container names for:
- Easy identification
- Simplified logging and monitoring
- Clear dependency management

### ✅ Logging Configuration
Standardized JSON logging with rotation:
- **Max size**: 10MB per file
- **Max files**: 3 rotated files
- **Format**: JSON for structured logging

### ✅ Dependencies
Services start in correct order using `depends_on` with health checks:
1. **Telemetry Stack**: OTEL Collector, OpenSearch, Tempo
2. **Monitoring**: Prometheus, Grafana, Alertmanager
3. **Development Tools**: Jenkins, SonarQube, Eclipse Che
4. **Collaboration**: Mattermost (with DB), Focalboard
5. **Infrastructure**: Harbor, Vault, Selenium Grid, Backstage

## Resource Requirements

### Minimum System Requirements
- **CPU**: 8 cores
- **RAM**: 16GB
- **Disk**: 100GB SSD

### Recommended System Requirements
- **CPU**: 16 cores
- **RAM**: 32GB
- **Disk**: 500GB SSD

### Per-Service Resource Allocation

#### Heavy Services (2+ cores, 2GB+ RAM)
- **SonarQube**: 2 CPU, 4GB RAM
- **Jenkins**: 2 CPU, 2GB RAM
- **Eclipse Che**: 2 CPU, 2GB RAM
- **OpenSearch**: 2 CPU, 2GB RAM
- **Selenium Nodes**: 1 CPU, 2GB RAM each

#### Medium Services (0.5-1 core, 512MB-1GB RAM)
- **Mattermost**: 1 CPU, 2GB RAM
- **Grafana**: 1 CPU, 1GB RAM
- **Prometheus**: 1 CPU, 2GB RAM
- **Harbor**: 1 CPU, 2GB RAM
- **OTEL Collector**: 1 CPU, 1GB RAM
- **Tempo**: 1 CPU, 1GB RAM
- **Backstage**: 1 CPU, 1GB RAM

#### Light Services (0.25-0.5 core, 256MB-512MB RAM)
- **Vault**: 0.5 CPU, 512MB RAM
- **Focalboard**: 0.5 CPU, 512MB RAM
- **Alertmanager**: 0.5 CPU, 256MB RAM
- **Traefik**: 0.5 CPU, 256MB RAM

## Pre-Deployment Checklist

### 1. Environment Variables
Create/update `.env` file with:
```bash
# Ports (if different from defaults)
JENKINS_PORT=8081
SONARQUBE_PORT=9000
GRAFANA_PORT=3000
# ... etc

# Secrets
VAULT_TOKEN=your-secure-token
GRAFANA_ADMIN_PASSWORD=your-secure-password
SONARQUBE_DB_PASSWORD=your-secure-password
MATTERMOST_DB_PASSWORD=your-secure-password

# Resource Limits
OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx1g
JENKINS_JAVA_OPTS=-Xmx2048m -Xms512m
```

### 2. Configuration Files
Review and customize:
- [configs/otel-config.yaml](configs/otel-config.yaml) - OTEL Collector settings
- [configs/prometheus.yml](configs/prometheus.yml) - Scrape targets
- [configs/alertmanager.yml](configs/alertmanager.yml) - Alert routing
- [configs/tempo.yaml](configs/tempo.yaml) - Trace storage
- [configs/grafana-dashboard.json](configs/grafana-dashboard.json) - Dashboards

### 3. Volume Backup Strategy
Set up regular backups for critical volumes:
```bash
# Jenkins data
docker run --rm -v jenkins_data:/data -v $(pwd)/backups:/backup \
  alpine tar czf /backup/jenkins-$(date +%Y%m%d).tar.gz /data

# SonarQube data
docker run --rm -v sonarqube_data:/data -v $(pwd)/backups:/backup \
  alpine tar czf /backup/sonarqube-$(date +%Y%m%d).tar.gz /data

# OpenSearch data
docker run --rm -v opensearch_data:/data -v $(pwd)/backups:/backup \
  alpine tar czf /backup/opensearch-$(date +%Y%m%d).tar.gz /data
```

### 4. Security Hardening

#### Network Security
- Use firewall to restrict port access
- Enable TLS/SSL for external-facing services
- Configure Traefik for HTTPS

#### Authentication
- Change default passwords immediately
- Enable OAuth/OIDC where supported
- Configure Vault for secrets management

#### Database Security
- Use strong database passwords
- Restrict database network access
- Enable database encryption at rest

### 5. Monitoring Setup

#### Metrics
- Verify Prometheus is scraping all targets
- Set up Grafana dashboards
- Configure alert rules

#### Logs
- Ensure logs are flowing to OpenSearch
- Set up log rotation and retention
- Configure log alerting

#### Traces
- Verify traces are reaching Tempo
- Set up trace sampling rules
- Configure trace retention

## Deployment Commands

### Initial Deployment
```bash
# 1. Pull all images
docker-compose pull

# 2. Start core services first (in order)
docker-compose up -d otel-collector opensearch tempo prometheus

# 3. Wait for health checks (check with)
docker-compose ps

# 4. Start remaining services
docker-compose up -d

# 5. Verify all services are healthy
docker-compose ps | grep -i "healthy"
```

### Rolling Updates
```bash
# Update single service
docker-compose pull <service-name>
docker-compose up -d --no-deps <service-name>

# Update all services
docker-compose pull
docker-compose up -d
```

### Graceful Shutdown
```bash
# Stop all services gracefully
docker-compose stop

# Or with timeout
docker-compose stop -t 30
```

## Health Check Verification

```bash
# Check all service health
docker-compose ps

# Check specific service logs
docker-compose logs -f <service-name>

# Check health check details
docker inspect <container-name> | jq '.[0].State.Health'

# Monitor resource usage
docker stats
```

## Troubleshooting

### Service Won't Start
1. Check logs: `docker-compose logs <service-name>`
2. Verify dependencies are healthy: `docker-compose ps`
3. Check resource availability: `docker stats`
4. Verify configuration files are mounted correctly

### Service Failing Health Checks
1. Check service-specific health endpoint manually
2. Increase `start_period` if service needs more startup time
3. Review service logs for errors
4. Verify network connectivity between services

### Performance Issues
1. Check resource limits: `docker stats`
2. Review service-specific metrics in Grafana
3. Check disk I/O: `iostat -x 1`
4. Review OpenSearch logs for storage issues

### Out of Memory
1. Increase service memory limits in respective yml files
2. Check for memory leaks in application logs
3. Adjust JVM settings for Java applications
4. Consider scaling horizontally

## Maintenance

### Log Rotation
Logs are automatically rotated with these settings:
- Max size: 10MB per file
- Max files: 3

### Database Maintenance
```bash
# PostgreSQL vacuum (SonarQube, Mattermost)
docker-compose exec <db-service> vacuumdb -U <user> -d <database> -v

# OpenSearch index management
curl -X DELETE "localhost:9200/otel-logs-*" -H 'Content-Type: application/json' \
  -d '{"query": {"range": {"@timestamp": {"lt": "now-30d"}}}}'
```

### Volume Cleanup
```bash
# Remove unused volumes
docker volume prune

# List volumes by size
docker system df -v
```

## Scaling Considerations

### Horizontal Scaling
Services that can be scaled horizontally:
- Selenium Chrome/Firefox nodes
- OTEL Collector (with load balancer)
- OpenSearch (cluster mode)

```bash
# Scale Selenium nodes
docker-compose up -d --scale chrome=3 --scale firefox=2
```

### Vertical Scaling
Adjust resource limits in service yml files:
```yaml
deploy:
  resources:
    limits:
      cpus: '4.0'
      memory: 8G
```

## Production Optimization Tips

1. **Use specific image tags** instead of `:latest` for reproducibility
2. **Enable persistent volumes** for all stateful services
3. **Set up monitoring alerts** for critical services
4. **Implement backup automation** for data volumes
5. **Use secrets management** (Vault) for sensitive data
6. **Enable SSL/TLS** for all external communications
7. **Implement rate limiting** in Traefik
8. **Set up log aggregation** and analysis
9. **Monitor disk usage** and set up alerts
10. **Regular security updates** for all images

## Support & Documentation

- Main README: [README.md](README.md)
- Service Documentation: Check individual `services/*.yml` files
- Configuration Examples: `configs/` directory
- Cleanup Script: [cleanup.sh](cleanup.sh)
