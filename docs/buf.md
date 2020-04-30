## Buf cheatsheets
We use the `auth` microservice in these examples.

### List packages in microservice
```
docker run \
  --volume "$(pwd):/workspace" \
  --workdir /workspace/alpacalabs/auth \
  bufbuild/buf image build --exclude-source-info -o -#format=json | jq '.file[] | .package' | sort | uniq | head
```

The output looks like you'd expect:
```
"google.protobuf"
"alpacalabs.auth.v1"
```

We import `google.protobuf` as our only dependency, and the package name for (this particular version of) 
the `auth` microservice is `alpacalabs.auth.v1`.

### Linting
```
docker run \
  --volume "$(pwd):/workspace" \
  --workdir /workspace/alpacalabs/auth \
  bufbuild/buf check lint
```

### Build an image
Any time Buf compiles Protocol Buffers, it builds an image.
This is central to how breaking change detection works.

```
docker run \
  --volume "$(pwd):/workspace" \
  --workdir /workspace/alpacalabs/auth \
  bufbuild/buf image build --exclude-source-info -o auth.buf.json
```

### Detect breaking change (compared to what is on `HEAD`)
```
docker run \
  --volume "$(pwd):/workspace" \
  --workdir /workspace/alpacalabs/auth \
  bufbuild/buf check breaking --against-input /workspace/alpacalabs/auth/auth.buf.json
```

This won't be sufficient to check for breaking changes in Buildkite.
Each PR build will have to compare its contents to master's.

### How do we choose the proper `--against-input`?
There are various ways to do this, listed [here](https://buf.build/docs/breaking-usage#decide-how-to-manage-your-previous-protobuf-schema-state-and-run-breaking-change-detection).

We can compare against an image from a cloud bucket, or an image built on-demand from `master`.