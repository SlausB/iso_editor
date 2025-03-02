#!/bin/bash
clear
reset

set -e

# application might store data in anonymous volumes which causes data persist among multiple runs which might clash with newly defined configuration (thus need to use --force-recreate):
docker compose down
docker compose up -d --build --force-recreate --renew-anon-volumes --remove-orphans
docker compose exec compiler bash
docker compose down
