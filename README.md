# Git Server Experiment

> Disclaimer: This project is an experiment and there is no intent to make it
> production-ready.

## Introduction

This project is a proof of concept implementation of a custom Git server. It is
written in Go and relies on the [`go-git`](https://github.com/go-git/go-git)
library to implement the Git Smart HTTP protocol (`git-receive-pack`,
`git-upload-pack`). Tested to ensure that the implementation is compatible with
the de facto Git implementation.

Unlike traditional Git server implementations that rely on file-system-based
"bare" repositories, this server abstracts data persistence through custom
storage interfaces, routing data to specialized systems:

**Object Storage (Ceph RGW)**: Git objects (blobs, trees, commits) are
  content-addressed and stored in an S3-compatible object store. This approach
  addresses scalability challenges associated with massive file counts (the
  "Small File Problem") by treating Git objects as immutable data blobs.

**Relational Metadata (PostgreSQL)**: Mutable repository data, such as
  references (branches, tags), are managed in a relational database to ensure
  transactional consistency while queries remain efficient.

This project serves as a sandbox for exploring ideas such as the ones listed
below, against standard Git workloads:

- [x] Implementing the Git/HTTP protocol with custom storage backends
- [ ] Using FastCDC for object data deduplication
- [ ] Using Merkle Trees for a multi-generational append-only object store
- [ ] Using swappable object and metadata stores

Developed with [Gemini Code Assist](https://codeassist.google/).

## Quick Start

The development environment is bootstrapped by a rather hacky set of scripts
contained in the `devenv` directory. For anything serious, I would recommend
using a more robust build system such as [Bazel](https://bazel.build/) instead.

### Prerequisites

- [Go](https://golang.org/dl/)
- [Make](https://www.gnu.org/software/make/)
- [Docker](https://www.docker.com/)
- [Node.js](https://nodejs.org/)
- [pnpm](https://pnpm.io/)
- [dbmate](https://github.com/amacneil/dbmate)
- [sqlc](https://sqlc.dev/)

### Setup

```bash
make devenv
```

This command will set up a Docker environment with
[MicroCeph](https://github.com/canonical/microceph) for S3-compatible object
storage and [PostgreSQL](https://www.postgresql.org/) for metadata storage.

### Build

```bash
make debug
```

### Run

```bash
./bin/git-server
```

Alternatively, you can run it from an IDE in debug mode. VSCode configs are
already included.

## Public API

### Repository Management

The server provides a simple REST API for managing repositories.

- `POST /repositories`: Create a new repository.
  - Body: `{"name": "repo-name"}`
- `GET /repositories/{id}`: Get repository details.
- `PUT /repositories/{id}`: Update repository (e.g., rename).
- `DELETE /repositories/{id}`: Delete a repository.

### Git Smart HTTP

The server implements the standard Git Smart HTTP protocol, allowing standard
Git clients to interact with hosted repositories.

- `GET /repositories/{id}/info/refs`: Service discovery and reference
  advertisement.
- `POST /repositories/{id}/git-upload-pack`: Handles `git fetch` and `git
  clone`.
- `POST /repositories/{id}/git-receive-pack`: Handles `git push`.

### Git over SSH

Not implemented yet.

## Implementation Details

This implementation deviates from standard directory-based Git servers in
several key ways:

### Git Storage

The project uses a custom implementation of `go-git`'s `Storer` interface. This
abstracts the underlying storage, allowing us to route:

- **Objects** (blobs, trees, commits) to **Ceph** (via `internal/objectstore`).
- **References** (branches, tags) to **PostgreSQL** (via `internal/metastore`).

### Object Storage

Objects are stored as "loose objects" in S3-compatible Ceph buckets under the
key pattern `repositories/{repo}/objects/{hash}`. The content is stored with the
standard Git header (`type size\0`) prepended, allowing for compatibility and
inspection.

To handle large pushes and avoid memory buffering issues, the server uses the
AWS SDK's S3 Uploader. This enables streaming of packet-line data directly to
Ceph without needing to seek the input stream.

### Quirks & Workarounds

#### Manual Packet-Line Parsing

During `git-receive-pack`, the server manually delimits the command packet-lines
from the packfile data stream. This is necessary to prevent `go-git`'s default
behavior from over-buffering or misinterpreting the stream boundaries when
piping directly to object storage.

### Persistence

The server now implements persistence for repository state in S3-compatible
storage:

- **Objects**: Stored as `repositories/{repo}/objects/{hash}`.
- **Config**: Repository configuration is stored at
  `repositories/{repo}/config`.
- **Shallow Commits**: Shallow commit hashes are stored at
  `repositories/{repo}/shallow`.
- **Index**: The staging area (index) is stored at `repositories/{repo}/index`.

### Limitations

**No Authentication**: The server is currently unprotected. Anyone can
read/write to any repository.

**Performance**: `IterEncodedObjects` (used for GC and some clones) lists keys
via S3 API, which may be slow for large repositories.

**No Packing**: Objects are stored strictly as loose objects. There is no
support for generating or storing packfiles (.pack/.idx) for storage
optimization.

## Documentation

Several topics are covered in greater detail in `docs/`:

- [Git Internals](docs/git-internals.md) - A quick intro into the structure of a
  Git repository.
- [PostgreSQL](docs/postgresql.md) - Describes how PostgreSQL is set up by the
  development environment.
- [Ceph](docs/ceph.md) - Describes how Ceph is set up by the development
  environment.

## License

Copyright © 2026, Claudiu Nedelcu. All rights reserved.<br />Licensed under the
[2-Clause BSD License](LICENSE.txt).
