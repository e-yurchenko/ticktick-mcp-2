#!/usr/bin/env bash
set -euo pipefail

DOTENV_DIR="${DOTENV_DIR:-/root/.config/ticktick-mcp}"
DOTENV_PATH="$DOTENV_DIR/.env"

mkdir -p "$DOTENV_DIR"

if [ ! -f "$DOTENV_PATH" ]; then
  REQUIRED_VARS=( \
    "TICKTICK_CLIENT_ID" \
    "TICKTICK_CLIENT_SECRET" \
    "TICKTICK_REDIRECT_URI" \
    "TICKTICK_USERNAME" \
    "TICKTICK_PASSWORD" \
  )

  missing=0
  for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var:-}" ]; then
      echo "Error: $var is not set in the environment." >&2
      missing=1
    fi
  done

  if [ "$missing" -ne 0 ]; then
    echo "Set the TickTick credentials before starting the server or mount a .env file at ${DOTENV_PATH}." >&2
    exit 1
  fi

  {
    for var in "${REQUIRED_VARS[@]}"; do
      printf '%s=%s\n' "$var" "${!var}"
    done
  } > "$DOTENV_PATH"

  echo "Created dotenv file at $DOTENV_PATH."
fi

cmd=("${@:-ticktick-mcp}")

has_dotenv=0
for arg in "${cmd[@]}"; do
  if [[ "$arg" == "--dotenv-dir" || "$arg" == --dotenv-dir=* ]]; then
    has_dotenv=1
    break
  fi
done

if [ "$has_dotenv" -eq 0 ]; then
  cmd+=("--dotenv-dir" "$DOTENV_DIR")
fi

exec "${cmd[@]}"
