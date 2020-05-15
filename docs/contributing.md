# Contributing

## How do I add a new service?
1. Create a private Github repo (**initialized with a README!!**) for your new SDK; its name should be of the form `protorepo-{serviceName}-{language}`.
Possible languages include: `go`, `csharp`, and many more.
1. As already stated: Make sure to initialize the new SDK's repo with an empty README, since the underlying build system we use
([published by namely](https://medium.com/namely-labs/how-we-build-grpc-services-at-namely-52a3ae9e7c35)) 
requires at least one commit in each repo before the build scripts can succeed.
1. Go to the repo's access page and grant admin permissions to the `CI/CD` GitHub team.
Our build system will need permissions to do its thing.
1. Add an entry to this repo's README with links to the new SDKs.
1. Commit and push your Protocol Buffers to this repo, and add an entry to this README with links to your service.

## Do not make Breaking Changes
The following is the list of changes understood to be breaking:

- Deleting or renaming a package.
- Deleting or renaming an enum, enum value, message, message field, service, or service method.
- Changing the type of a message field.
- Changing the tag of a message field.
- Changing the label of a message field, i.e. optional, repeated, required.
- Moving a message field currently in a oneof out of the oneof.
- Moving a message field currently not in a oneof into the oneof.
- Changing the function signature of a method.
- Changing the stream value of a method request or response.

Avoid breaking changes at all costs.

## Package versioning
Make a new package in lieu of breaking changes.

## Deprecations
Instead of making a breaking change, rely on deprecation of types.

```proto
// Note that all enums, messages, services, and service methods require
// sentence comments, and each service must be in a separate file, as
// outlined below, however we omit this here for brevity.

enum Foo {
  option deprecated = true;
  FOO_INVALID = 0;
  FOO_ONE = 1;
}

enum Bar {
  BAR_INVALID = 0;
  BAR_ONE = 1 [deprecated = true];
  BAR_TWO = 2;
}

message Baz {
  option deprecated = true;
  int64 one = 1;
}

message Bat {
  int64 one = 1 [deprecated = true];
  int64 two = 2;
}

service BamAPI {
  option deprecated = true;
  rpc Hello(HelloRequest) returns (HelloResponse) {}
}

service BanAPI {
  rpc SayGoodbye(SayGoodbyeRequest) returns (SayGoodbyeResponse) {
    option deprecated = true;
  }
}
```

## Reserved Keyword
Do not use the `reserved` keyword in messages or enums. Instead, rely on the `deprecated` option.

The following is an example of what not to do.

```proto
// A user.
message User {
  // Do not do this.
  reserved 2, 4;
  reserved "first_name", "middle_names"

  string id = 1;
  string last_name = 3;
  repeated string first_names = 4;
}

// The type of the trip.
enum TripType {
  // Do not do this.
  reserved 2;
  reserved "TRIP_TYPE_POOL";

  TRIP_TYPE_INVALID = 0;
  TRIP_TYPE_UBERX = 1;
  TRIP_TYPE_UBER_POOL = 3;
}
```

Instead, do the following.

```proto
// A user.
message User {
  string id = 1;
  string last_name = 3;
  repeated string first_names = 5;

  string first_name = 2 [deprecated = true];
  repeated string middle_names = 4 [deprecated = true];
}

// The type of the trip.
enum TripType {
  TRIP_TYPE_INVALID = 0;
  TRIP_TYPE_UBERX = 1;
  TRIP_TYPE_UBER_POOL = 3;

  TRIP_TYPE_POOL = 2 [deprecated = true];
}
```

By far the most important reason to use `deprecated` instead of `reserved` is that while not a wire
breaking change, deleting a field or enum value is a source code breaking change. This will result
in code that does not compile, which we take a strong stance against, including in Prototool's
breaking change detector. Your API as a whole should not need semantic versioning - one of the core
promises of Protobuf is forwards and backwards compatibility, and this should extend to your
code as well. This is especially true if your Protobuf definitions are used across multiple
repositories, and even if you have a single monorepo for your entire organization, any external
customers who use your Protobuf definitions should not be broken either.
