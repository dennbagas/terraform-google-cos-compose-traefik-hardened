#!/bin/sh
export PGPASSWORD=$POSTGRESQL_PASSWORD
echo "Creating database if not exists"
psql -U postgres -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'my-db'" | grep -q 1 || psql -U postgres -d postgres -c "CREATE DATABASE my-db"
