FROM python:3.12-slim

WORKDIR /app

# System dependencies (Pillow + Playwright Chromium)
RUN apt-get update && apt-get install -y \
    gcc g++ \
    libjpeg-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright's Chromium browser + its OS-level deps
RUN playwright install chromium && playwright install-deps chromium

# Copy Django project
COPY concept360/ .

# Create volume mount points so Docker named volumes attach cleanly
RUN mkdir -p /app/data /app/media /app/temp_excel

# Entrypoint: runs migrate then starts Daphne
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8002

ENTRYPOINT ["/entrypoint.sh"]
