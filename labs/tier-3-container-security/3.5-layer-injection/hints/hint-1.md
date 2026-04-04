A container image manifest lists layers in order. An attacker with
registry write access can modify the manifest to add an extra layer.

Start by checking the layer count of the original and modified images:

```
# Expected layer count (from the clean Dockerfile)
crane manifest registry:5000/webapp:clean | jq '.layers | length'

# Actual layer count in the suspect image
crane manifest registry:5000/webapp:latest | jq '.layers | length'
```

If the counts differ, an extra layer was injected. To find it, compare
the layer digests:

```
crane manifest registry:5000/webapp:clean | jq -r '.layers[].digest'
crane manifest registry:5000/webapp:latest | jq -r '.layers[].digest'
```

The extra digest in the second list is the injected layer.
