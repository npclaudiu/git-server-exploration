
# PostgreSQL

PostgreSQL is used for metadata storage (everything but objects and packs). It
runs in a Docker container named `postgres`.

## Configuration

- **Version**: 18.1
- **Port**: 5432 (Mapped to host port 5432)
- **Database**: `git-server`
- **User**: `minerva`
- **Password**: `m1n3rv@`

## Schema Management

We use [dbmate](https://github.com/amacneil/dbmate) for database schema
migrations.

**Run Migrations:**

```bash
make ms-migrate
```

## Code Generation

We use [sqlc](https://sqlc.dev/) to generate Go code from SQL queries.

**Generate Code:**

```bash
make ms-gen
```

## Common Commands

```bash
# Connect to database in interactive mode:
./devenv/bin/psql

# List databases:
./devenv/bin/psql -l

# List tables:
./devenv/bin/psql -c "\dt"

# List columns of a table:
./devenv/bin/psql -c "\d+ table_name"

# List indexes of a table:
./devenv/bin/psql -c "\di+ table_name"

# List sequences of a table:
./devenv/bin/psql -c "\ds+ table_name"
```
