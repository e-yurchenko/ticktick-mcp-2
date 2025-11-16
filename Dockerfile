FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DOTENV_DIR=/home/ticktick/.config/ticktick-mcp \
    HOME=/home/ticktick

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos "" ticktick

WORKDIR /app

COPY pyproject.toml uv.lock ./
COPY src ./src

RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir git+https://github.com/jen6/ticktick-py.git@ae11d15cab230ad70983ceaa970c4e952f1be918
RUN pip install --no-cache-dir .

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN chown -R ticktick:ticktick /app /home/ticktick

USER ticktick

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["ticktick-mcp"]
