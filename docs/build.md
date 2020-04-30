# Build strategy
This repo is meant only to contain Protocol Buffers.

The language targets that each service builds for are contained in the 
[`.protolangs`](https://github.com/AlpacaLabs/protorepo/blob/master/billing/.protolangs) file in each directory.
(Importantly, that file must end in a newline, otherwise, the build script will fail).

When our build tool sees that the `billing` service is built for `go`, it will push the compiled definitions
to [`protorepo-billing-go`](https://github.com/AlpacaLabs/protorepo-billing-go).

The bash script that does this is stolen from [here](https://gist.github.com/bobbytables/2fab9ac9509867b5acfe2bb5693aee71).

The entire strategy is laid out in this [blog post](https://medium.com/namely-labs/how-we-build-grpc-services-at-namely-52a3ae9e7c35).