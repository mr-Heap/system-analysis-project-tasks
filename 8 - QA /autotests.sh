#!/bin/bash

echo "Установка необходимых зависимостей..."
API=localhost:8080
COLLECTION_FILE=tests.json
REPORT_DIR="./newman-reports"
HTML_REPORT="$REPORT_DIR/report.html"

npm install -g newman newman-reporter-html newman-reporter-htmlextra

echo "Запуск тестов Postman через Newman..."
newman run "$COLLECTION_FILE" \
	--env-var "baseUrl=$API" \
	-r cli,htmlextra \
	--reporter-htmlextra-export "$HTML_REPORT"

