#### Casing of `Id` suffix
The Go `lint` tool is picky about writing `ID` instead of `Id`.

However, when we abide by the conventional style guide laid out by Google/Uber/Buf, we have to snake_case field names,
which means a field like `device_id` will be auto-generated to `deviceId` in Go code, which will cause the Go linter
to complain. The Go maintainers have been adamant about not relaxing this rule, so Go lint will just have to deal with it.
(See [here](https://github.com/golang/lint/issues/89), 
[here](https://github.com/golang/lint/issues/124), and
[here](https://github.com/golang/lint/issues/216)).

#### `RPC_REQUEST_STANDARD_NAME` and `RPC_RESPONSE_STANDARD_NAME`
All requests must end in `Request`. All responses must end in `Response`.
This just makes APIs much more usable and conformant.

#### `RPC_REQUEST_RESPONSE_UNIQUE`
One of the single most important rules to enforce in modern Protobuf development is to have a unique request and 
response message for every RPC. Separate RPCs should not have their request and response parameters controlled by 
the same Protobuf message, and if you share a Protobuf message between multiple RPCs, this results in multiple RPCs 
being affected when fields on this Protobuf message change. Even in simple cases, best practice is to always have a 
wrapper message for your RPC request and response types.

#### `COMMENTS`
We should definitely use this considering:
> Buf intends to host a documentation service (both public and on-prem) in the future, 
> which may include a structured documentation scheme.

#### `UNARY_RPC`
Checks that RPCs are not client streaming or server streaming.

This [discussion](https://github.com/twitchtv/twirp/issues/70#issuecomment-470367807) enumerates
some concerns with gRPC streaming.

CLS, the client-library-service, has certainly had some issues with streaming when downloading
metadata from Citadel.