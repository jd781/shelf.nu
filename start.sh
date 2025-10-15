#!/bin/sh -ex

# This file is how Fly starts the server (configured in fly.toml). 
# Migrations are already run during the build phase in the Dockerfile

# Start the server
npm run start
