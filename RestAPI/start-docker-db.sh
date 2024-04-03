#!/bin/bash
# Use this script to start a docker container for a local development database

DB_CONTAINER_NAME="pkmntb-postgres"
DB_NAME="pkmntb"

if [ "$(docker ps -q -f name=$DB_CONTAINER_NAME)" ]; then
  docker start $DB_CONTAINER_NAME
  echo "DB container started"
  exit 0
fi

# import env variables from .env
cp .env.example .env

set -a
source .env

DB_PASSWORD=$(echo $DATABASE_URL | awk -F':' '{print $3}' | awk -F'@' '{print $1}')

if [ "$DB_PASSWORD" = "password" ]; then
  echo "You are using the default database password, will generate a new one"
  DB_PASSWORD=$(openssl rand -base64 12)
  sed -i -e "s#:password@#:$DB_PASSWORD@#" .env
fi

docker run --name $DB_CONTAINER_NAME -e POSTGRES_PASSWORD=$DB_PASSWORD -e POSTGRES_DB=$DB_NAME -d -p 5432:5432 docker.io/postgres

echo "DB container was successfully created"
