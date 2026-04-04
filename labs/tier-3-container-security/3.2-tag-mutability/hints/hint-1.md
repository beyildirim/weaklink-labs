A tag like `webapp:1.0.0` is just a pointer to a digest. Unlike digests
(which are content-addressable hashes), tags can be moved at any time.

To see the actual digest a tag points to:

```
crane digest registry:5000/webapp:1.0.0
```

Or with docker:

```
docker inspect --format='{{.RepoDigests}}' registry:5000/webapp:1.0.0
```

Now push the backdoored image with the same tag and check the digest again.
It changed -- same tag, completely different image.

The fix is to reference images by their digest instead of their tag.
