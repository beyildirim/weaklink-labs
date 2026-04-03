FROM squidfunk/mkdocs-material:latest
COPY guide/ /docs/
EXPOSE 8000
ENTRYPOINT ["mkdocs", "serve", "--dev-addr=0.0.0.0:8000"]
