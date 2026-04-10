FROM squidfunk/mkdocs-material:latest AS builder

WORKDIR /docs
ARG SITE_URL=""
ENV SITE_URL=${SITE_URL}
COPY . /docs/
RUN mkdocs build --strict

FROM cgr.dev/chainguard/python@sha256:d827d0d1fe441f5f6d2e8b8efe2dad181a9dd5b6e34c22798e7b809349f5d520

COPY --from=builder /docs/site /site
WORKDIR /site
EXPOSE 8000
CMD ["-m", "http.server", "8000", "--directory", "/site"]
