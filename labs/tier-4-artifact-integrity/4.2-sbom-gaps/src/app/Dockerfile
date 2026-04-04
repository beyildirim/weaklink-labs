FROM python:3.11-slim
RUN apt-get update && apt-get install -y curl jq
RUN pip install flask==3.0.0
# This binary dependency won't show up in pip-based SBOM tools
RUN curl -LO https://github.com/example/tool/releases/download/v1.0/tool-linux-amd64 || true
COPY app.py .
CMD ["python", "app.py"]
