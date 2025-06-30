#!/bin/bash

echo "🧼 Limpando ambiente Docker..."
docker compose down -v --remove-orphans && docker system prune -af --volumes
