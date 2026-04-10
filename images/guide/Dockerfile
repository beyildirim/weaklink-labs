FROM squidfunk/mkdocs-material:latest AS builder

WORKDIR /docs
ARG SITE_URL=""
ENV SITE_URL=${SITE_URL}
COPY . /docs/
RUN mkdocs build --strict

FROM python:3.11-alpine

WORKDIR /site
COPY --from=builder /docs/site /site
EXPOSE 8000
CMD ["python", "-m", "http.server", "8000", "--directory", "/site"]
