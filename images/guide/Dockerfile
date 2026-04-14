FROM squidfunk/mkdocs-material:latest AS builder

WORKDIR /docs
ARG SITE_URL=""
ENV SITE_URL=${SITE_URL}
COPY . /docs/
RUN mkdocs build --strict

FROM gcr.io/distroless/python3-debian12:nonroot@sha256:7d1042ce588ab97019fe95c24ffca7bc5a82ccdac572511d5e09bda4435c89c5

COPY --from=builder /docs/site /site
WORKDIR /site
EXPOSE 8000
CMD ["-m", "http.server", "8000", "--directory", "/site"]
