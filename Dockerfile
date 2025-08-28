# syntax=docker/dockerfile:1.7
FROM python:3.12-slim AS runtime

# Prevent Python from writing .pyc files and ensure stdout/stderr are unbuffered
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Working directory inside the container
WORKDIR /app

# Install system dependencies (minimal)
RUN apt-get update -y && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

# Install Python dependencies directly (aligns with pyproject.toml)
# Using pip instead of uv for simplicity inside the container
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir "fastmcp>=2.11.3" "httpx>=0.28.1" "mcp[cli,sse]>=1.13.1" "python-dotenv>=1.1.1" "uvicorn>=0.35.0"

# Copy application code
COPY server.py ./ 

# Expose environment variable (documented; actual value should be provided at runtime)
# You can set this via: docker run -e FINANCIAL_DATASETS_API_KEY=... image
ENV FINANCIAL_DATASETS_API_KEY=""

EXPOSE 9000

CMD ["python", "server.py"]
