# protorepo

A monorepo for all our [Protocol Buffers](https://developers.google.com/protocol-buffers).

## FAQ
### What services exist? 
Each directory corresponds to a microservice and specifies all provided Protocol Buffers and gRPC endpoints.

| Service                                                                                    | Bindings                                                               |
| ------------------------------------------------------------------------------------------ |:----------------------------------------------------------------------:|
| [Auth](https://github.com/AlpacaLabs/protorepo/tree/master/alpacalabs/auth/v1)             | [go](https://github.com/AlpacaLabs/protorepo-auth-go)                  |
| [Hermes](https://github.com/AlpacaLabs/protorepo/tree/master/alpacalabs/hermes/v1)         | [go](https://github.com/AlpacaLabs/protorepo-hermes-go)                |
| [Pagination](https://github.com/AlpacaLabs/protorepo/tree/master/alpacalabs/pagination/v1) | [go](https://github.com/AlpacaLabs/protorepo-pagination-go)            |

### What is a Protocol Buffer?
From the [docs](https://developers.google.com/protocol-buffers):
> Protocol buffers are Google's language-neutral, platform-neutral, extensible mechanism for serializing structured 
> data – think XML, but smaller, faster, and simpler. You define how you want your data to be structured once, then 
> you can use special generated source code to easily write and read your structured data to and from a variety of 
> data streams and using a variety of languages.

"Language-neutral" means a Protocol Buffer is independent of any well-known programming language.
It is an interface description language. It's not written in Javascript, Go, or C#. But it can be compiled
to those languages!

"Platform-neutral" means they aren't tethered to any framework of those languages.

"Extensible" refers to the way versioning works in Protocol Buffers; fields never get renamed or re-ordered; when a
field is deleted, its number is reserved; backwards-compatibility is always preserved:
> New fields could be easily introduced, and intermediate servers that didn’t need to inspect the data could simply 
> parse it and pass through the data without needing to know about all the fields.

### What is gRPC?
From the [docs](https://grpc.io/):
> gRPC is a modern open source high performance RPC framework that can run in any environment. It can efficiently 
> connect services in and across data centers with pluggable support for load balancing, tracing, health checking 
> and authentication. It is also applicable in last mile of distributed computing to connect devices, mobile 
> applications and browsers to backend services.

### How do I contribute?
See our [docs](docs/contributing.md).

### How does the Build Strategy work?
See our [docs](docs/build.md).

### What are the conventional linting standards?
See our [docs](docs/linting.md).

### TODO / Challenges
- Experimental changes require PR approvals.
- We don't have a good tagging system.
Microservices import protorepo SDKs by the latest commit hash,
not by a well-known, human-readable tag. 
- Remote branches don't get deleted.
This can be a problem if you make a `pr-1` branch, delete it, 
and then some time later make a branch with the same name.
[Deleting remote branches is easy](https://www.hacksparrow.com/git/delete-all-remote-branches-except-master.html).
The challenge would be to only delete remote SDK 
branches once the protorepo branch has been merged. 