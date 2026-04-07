Multi-stage builds are supposed to keep build-time secrets out of the
final image. But secrets leak in three common ways:

1. **ENV/ARG baked into layer metadata.** `docker history` reveals them
2. **Files copied from build stage.** May carry metadata or embedded secrets
3. **Environment variables inherited.** ENV persists across stages

Check the vulnerable image for leaks:

```
# Check history for secret values
docker history --no-trunc registry:5000/myapp:vulnerable

# Check environment variables in the running container
docker run --rm registry:5000/myapp:vulnerable env

# Search for the secret string in the filesystem
docker run --rm registry:5000/myapp:vulnerable grep -r "s3cr3t" /app/ /tmp/ 2>/dev/null
```

You should find the API key exposed via at least one of these methods.
