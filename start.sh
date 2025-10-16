#!/bin/sh
set -e

# This file is how Fly starts the server (configured in fly.toml). 
# Run migrations before starting the server (secrets are available at runtime)
npx prisma migrate deploy --schema=./app/database/schema.prisma

# Start the server directly (environment variables are already injected by Fly.io)
exec node ./build/server/index.js
