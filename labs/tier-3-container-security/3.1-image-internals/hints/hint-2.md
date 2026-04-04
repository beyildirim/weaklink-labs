To extract and inspect individual layers, save the image as a tar archive
and unpack it:

```
docker save registry:5000/webapp:latest -o webapp.tar
mkdir /app/extracted-layers
tar xf webapp.tar -C /app/extracted-layers
```

Inside the extracted directory, each layer is a directory with a `layer.tar`.
Extract each one and look for unexpected files:

```
cd /app/extracted-layers
for layer in */layer.tar; do
    echo "=== $layer ==="
    tar tf "$layer" | head -20
done
```

You can also use crane to inspect the manifest directly:

```
crane manifest registry:5000/webapp:latest | jq .
```

Document what you find in `/app/findings.txt` -- include the layer hash
and the hidden filename.
