First, try deploying the unsigned image and notice nothing stops you:

```
kubectl run test --image=registry:5000/weaklink-app:unsigned
kubectl get pods
```

No warnings, no errors. That's the problem.

To generate a cosign key pair:

```
cosign generate-key-pair
```

This creates `cosign.key` (private) and `cosign.pub` (public). Move them
to `/app/`:

```
mv cosign.key cosign.pub /app/
```
