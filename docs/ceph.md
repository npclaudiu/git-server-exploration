
# Ceph

MicroCeph is used to provide an S3-compatible object storage service (RGW) for
storing Git objects. The entire Ceph cluster runs inside a single Docker
container named `microceph`.

## Cluster Topology

The Ceph cluster is configured as a single-node cluster with the following
components:

- **Monitors (MONs)**: 1 (Integrated single-node default)
- **Managers (MGRs)**: 1 (Integrated single-node default)
- **Metadata Servers (MDSs)**: 1 (Enabled during bootstrap)
- **OSDs (Object Storage Daemons)**: 3
  - Type: Loopback file-backed
  - Size: 4GB each
  - Configuration Command: `microceph disk add loop,4G,3`

## RGW Setup

The Rados Gateway (RGW) is enabled to provide the S3 API.

- **Service Name**: `rgw`
- **Port**: 8000 (Mapped to host port 8000)

A default user is automatically created by the `devenv` script to generate
S3-like RGW access and secret keys, which are then written to `config.yaml`.

## Invoking Binaries

Since Ceph runs inside a Docker container using `snapd`, the binaries are
installed in `/snap/bin/`. You can invoke them from the host machine using
`docker exec`. The generic pattern to run any Ceph command is:

```bash
docker exec microceph /snap/bin/<binary_name> [arguments]
```

However, for the most common commands, this project provides wrapper scripts in
`./devenv/bin`.

## Common Commands

```bash
# Check Cluster Status:
./devenv/bin/microceph status

# Check Ceph Health:
./devenv/bin/ceph -s

# List RGW Users:
./devenv/bin/radosgw-admin user list

# Create RGW User:
./devenv/bin/radosgw-admin user create --uid="hercules" --display-name="Hercules"

# User status:
./devenv/bin/radosgw-admin user info --uid="hercules"

# Delete RGW User:
./devenv/bin/radosgw-admin user rm --uid="hercules"

# Bucket stats:
./devenv/bin/radosgw-admin bucket stats --bucket=git-objects
```
