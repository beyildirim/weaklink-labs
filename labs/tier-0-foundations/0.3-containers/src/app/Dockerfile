FROM python:3.11-slim

LABEL maintainer="lab@example.com"
LABEL version="1.0.0"
LABEL description="A simple web app for the container security lab"

WORKDIR /app

COPY app.py .

EXPOSE 8000

HEALTHCHECK --interval=5s --timeout=3s \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["python", "app.py"]
