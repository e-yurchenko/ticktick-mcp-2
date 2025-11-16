FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DOTENV_DIR=/home/ticktick/.config/ticktick-mcp \
    HOME=/home/ticktick \
    FASTMCP_HOST=0.0.0.0 \
    FASTMCP_PORT=8080 \
    FASTMCP_LOG_LEVEL=INFO

EXPOSE 8080

RUN adduser --disabled-password --gecos "" ticktick

WORKDIR /app

COPY pyproject.toml uv.lock ./
COPY src ./src

RUN apt-get update \
    && apt-get install -y --no-install-recommends git build-essential \
    && pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir git+https://github.com/jen6/ticktick-py.git@ae11d15cab230ad70983ceaa970c4e952f1be918 \
    && pip install --no-cache-dir . \
    && apt-get purge -y --auto-remove git build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN chown -R ticktick:ticktick /app /home/ticktick

USER ticktick

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["ticktick-mcp"]
