Create a fixed Dockerfile at `/app/Dockerfile.fixed` that uses BuildKit
secrets instead of ENV/ARG:

```dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.22 AS builder
WORKDIR /src
COPY go.* ./
RUN go mod download
COPY . .
# Secret is mounted at build time, never stored in a layer
RUN --mount=type=secret,id=api_key \
    API_KEY=$(cat /run/secrets/api_key) \
    go build -ldflags "-X main.version=1.0.0" -o /app/server .

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /app/server /app/server
ENTRYPOINT ["/app/server"]
```

Build with the secret passed via BuildKit:

```
echo "s3cr3t_k3y_value" > /tmp/api_key.txt
DOCKER_BUILDKIT=1 docker build \
    --secret id=api_key,src=/tmp/api_key.txt \
    -t registry:5000/myapp:secure \
    -f /app/Dockerfile.fixed /app/
docker push registry:5000/myapp:secure
rm /tmp/api_key.txt
```

Also create `/app/.dockerignore` to prevent accidental context leaks:

```
.env
*.secret
credentials*
.git
```

Verify no secrets leak in the final image:

```
docker history --no-trunc registry:5000/myapp:secure
docker run --rm registry:5000/myapp:secure env
```
