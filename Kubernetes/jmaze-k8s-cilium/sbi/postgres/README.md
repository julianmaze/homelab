# PostgreSQL Database for SBI Financial Data

This directory contains Kubernetes manifests for deploying a PostgreSQL database using Docker Hardened Images (DHI) to store financial data for personal projects.

## Overview

- **Image**: `dhi.io/postgres:16`
- **Namespace**: `sbi`
- **Purpose**: Single-instance PostgreSQL database for financial data storage
- **Storage**: Uses existing PVC `sbi-postgres` in the `sbi` namespace

## Architecture

This is a single-pod deployment without replication, suitable for personal projects and development use cases.

### Components

- **Deployment**: Single replica PostgreSQL 16 container
- **Service**: ClusterIP service exposing port 5432
- **Secret**: Database credentials (user, password, database name)
- **Storage**: Persistent volume claim `sbi-postgres`

## Files

- `deployment.yaml` - PostgreSQL deployment configuration
- `service.yaml` - ClusterIP service definition
- `secret.yaml` - Database credentials (update before deploying)
- `kustomization.yaml` - Kustomize configuration for easy deployment
- `dhi_guide.md` - Reference guide for Docker Hardened PostgreSQL images

## Prerequisites

1. Namespace `sbi` must exist
2. PersistentVolumeClaim `sbi-postgres` must be created in the `sbi` namespace

## Deployment

### 1. Update Credentials

**Important**: Before deploying, update the password in `secret.yaml`:

```yaml
stringData:
  POSTGRES_PASSWORD: changeme-use-strong-password # Change this!
```

### 2. Deploy with Kustomize

```bash
kubectl apply -k ./Kubernetes/jmaze-k8s-cilium/sbi/postgres/
```

Or deploy individually:

```bash
kubectl apply -f secret.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### 3. Verify Deployment

```bash
# Check pod status
kubectl get pods -n sbi -l app=postgres

# Check service
kubectl get svc -n sbi postgres

# View logs
kubectl logs -n sbi -l app=postgres
```

## Configuration

### Environment Variables

The deployment uses the following environment variables from the secret:

- `POSTGRES_USER`: Database superuser (default: `postgres`)
- `POSTGRES_PASSWORD`: Database password (must be set)
- `POSTGRES_DB`: Default database name (default: `financial_data`)
- `POSTGRES_INITDB_ARGS`: Initialization arguments (`--encoding=UTF8 --locale=C`)

### Resources

- **Requests**: 256Mi memory, 250m CPU
- **Limits**: 1Gi memory, 1000m CPU

Adjust these in `deployment.yaml` based on your workload requirements.

### Storage

The volume is mounted to `/var/lib/postgresql` following DHI best practices. The image automatically creates the versioned subdirectory (`/var/lib/postgresql/16/data`).

## Connecting to the Database

### From within the cluster

Connection string:

```
postgres://postgres:<password>@postgres.sbi.svc.cluster.local:5432/financial_data
```

Service DNS names:

- Within `sbi` namespace: `postgres:5432`
- From other namespaces: `postgres.sbi.svc.cluster.local:5432`

### Using psql client

```bash
# Connect to the database
kubectl exec -it -n sbi deployment/postgres -- psql -U postgres -d financial_data

# Run a query
kubectl exec -it -n sbi deployment/postgres -- psql -U postgres -d financial_data -c "SELECT version();"
```

## Backup and Restore

### Create a backup

```bash
kubectl exec -n sbi deployment/postgres -- pg_dump -U postgres financial_data > backup.sql
```

### Restore from backup

```bash
kubectl exec -i -n sbi deployment/postgres -- psql -U postgres financial_data < backup.sql
```

### Backup all databases

```bash
kubectl exec -n sbi deployment/postgres -- pg_dumpall -U postgres > backup-all.sql
```

## Monitoring

### Check database activity

```bash
kubectl exec -n sbi deployment/postgres -- psql -U postgres -c "SELECT * FROM pg_stat_activity;"
```

### Health checks

The deployment includes:

- **Liveness probe**: Checks if PostgreSQL is responsive using `pg_isready`
- **Readiness probe**: Ensures PostgreSQL is ready to accept connections

## Troubleshooting

### View logs

```bash
kubectl logs -n sbi -l app=postgres -f
```

### Debug with Docker Debug

Since DHI images don't include debugging tools, use Docker Debug:

```bash
kubectl debug -it -n sbi deployment/postgres --image=busybox --target=postgres
```

### Check pod events

```bash
kubectl describe pod -n sbi -l app=postgres
```

### Verify PVC is bound

```bash
kubectl get pvc -n sbi sbi-postgres
```

## Security Notes

- Runs as `nonroot` user (DHI default)
- Minimal attack surface (no package manager in runtime image)
- Credentials stored in Kubernetes secrets
- Uses SIGINT for graceful shutdown (30-second grace period)

## DHI-Specific Features

This deployment follows Docker Hardened Images best practices:

1. **Versioned PGDATA**: Automatically managed at `/var/lib/postgresql/16/data`
2. **Parent directory mount**: Volume mounted to `/var/lib/postgresql` for easier upgrades
3. **Security hardened**: Minimal base image with security patches
4. **Complete toolkit**: Includes all PostgreSQL tools (psql, pg_dump, etc.)

## Scaling Considerations

This is a single-pod deployment. For production use cases requiring high availability:

- Consider PostgreSQL operators (e.g., Zalando Postgres Operator, CloudNativePG)
- Implement replication and failover
- Use StatefulSets instead of Deployments
- Configure backup strategies with dedicated tools

## References

- [DHI PostgreSQL Guide](./dhi_guide.md)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/16/)
