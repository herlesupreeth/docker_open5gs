#!/bin/bash
# Run this before you run a docker-compose build --no-cache
# in order to generate files from .env

cp -fv .env srslte/
cp -fv .env dns/
