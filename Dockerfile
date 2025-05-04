# Stage 1: Builder with compiled dependencies
FROM python:3.9-slim as builder

# Install build essentials and TA-Lib dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Compile TA-Lib from source
RUN wget https://downloads.sourceforge.net/project/ta-lib/ta-lib/0.4.0/ta-lib-0.4.0-src.tar.gz && \
    tar -xzf ta-lib-0.4.0-src.tar.gz && \
    cd ta-lib/ && \
    ./configure --prefix=/usr && \
    make && \
    make install

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install psutil gunicorn

# Stage 2: Minimal runtime image
FROM python:3.9-slim

WORKDIR /app

# Copy only necessary artifacts
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /usr/lib/libta_lib.* /usr/lib/
COPY --from=builder /usr/include/ta-lib /usr/include/ta-lib

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Copy application
COPY src/ src/
COPY config/ config/
COPY scripts/ scripts/

# Environment setup
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV TZ=UTC

# Security
RUN groupadd -r trader && \
    useradd -r -g trader trader && \
    chown -R trader:trader /app
USER trader

# Health checks
HEALTHCHECK --interval=30s --timeout=10s \
    CMD python -c "import requests; requests.get('http://localhost:8000/health', timeout=5)"

# Entrypoint
ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "src.core.wsgi:app"]
