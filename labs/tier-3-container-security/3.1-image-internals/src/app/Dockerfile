FROM python:3.11-slim
LABEL maintainer="weaklink-labs"
WORKDIR /app
COPY app.py .
# Intentionally store a secret in a layer (then "remove" it)
COPY secret.conf /tmp/secret.conf
RUN cat /tmp/secret.conf && rm /tmp/secret.conf
EXPOSE 8080
CMD ["python", "app.py"]
