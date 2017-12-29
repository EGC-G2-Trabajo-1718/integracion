#!/usr/bin/env bash

cd /app

if [ -d "/app/censos" ]; then
    pip install -r requirements.txt
    cd censos
else
    pip install -r requirements.txt
fi

python manage.py makemigrations
python manage.py migrate
python manage.py runserver 0.0.0.0:80
