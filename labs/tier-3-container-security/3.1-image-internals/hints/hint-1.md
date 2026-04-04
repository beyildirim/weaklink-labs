A container image is not a single blob -- it is a stack of layers.
Each `RUN`, `COPY`, or `ADD` instruction in a Dockerfile creates a new layer.

When a layer "deletes" a file, it only marks it as deleted (a whiteout) in
that layer. The file still exists in the earlier layer.

Start by looking at ALL layers, not just the final filesystem:

```
docker history --no-trunc registry:5000/webapp:latest
```

Compare this to the shorter output from:

```
docker inspect registry:5000/webapp:latest
```

The history shows every layer's command. Look for suspicious `COPY` or
`RUN` commands that add files which are later "removed".
