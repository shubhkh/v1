#!/bin/sh
set -e

python manage.py migrate --no-input

exec daphne -b 0.0.0.0 -p 8002 concept360.asgi:application
