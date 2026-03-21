FROM docker.io/edumgt/platform-python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

ARG PIP_INDEX_URL
ARG PIP_TRUSTED_HOST

WORKDIR /app

COPY requirements.txt .
RUN if [ -n "${PIP_INDEX_URL:-}" ]; then \
      if [ -n "${PIP_TRUSTED_HOST:-}" ]; then \
        pip install --no-cache-dir --index-url "${PIP_INDEX_URL}" --trusted-host "${PIP_TRUSTED_HOST}" -r requirements.txt; \
      else \
        pip install --no-cache-dir --index-url "${PIP_INDEX_URL}" -r requirements.txt; \
      fi; \
    else \
      pip install --no-cache-dir -r requirements.txt; \
    fi

COPY app ./app

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
