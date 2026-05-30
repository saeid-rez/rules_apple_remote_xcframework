# rules_apple_remote_xcframework

A Bazel module for consuming remote XCFrameworks for iOS/MacOS applications.

Tested with Bazel `8.x` and `9.x`.

## Installation

Add the following to your `MODULE.bazel` file:

```starlark
bazel_dep(name = "rules_apple_remote_xcframework", version = "1.0.1")

remote_xcframework = use_extension(
    "@rules_apple_remote_xcframework//remote_xcframework:extensions.bzl",
    "remote_xcframework_extension",
)

remote_xcframework.xcframework(
    name = "MyRemoteFramework",
    url = "https://my.server.com/path/to/MyFramework.xcframework.zip",
    sha256 = "...",
    strip_prefix = "MyFramework-1.2.3",
)

use_repo(remote_xcframework, "MyRemoteFramework")
```

This module depends on `rules_apple` and `rules_swift` and is intended for Bzlmod-based projects.

## Usage

You can now depend on the downloaded framework in your `swift_library` or `ios_application` targets:

```starlark
swift_library(
    name = "my_lib",
    srcs = ["..."],
    deps = [
        "@MyRemoteFramework//:MyRemoteFramework",
    ],
)
```

See `examples/` for a working end-to-end example.

## Framework Types

The extension supports both dynamic and static XCFrameworks. By default, frameworks are treated as dynamic.

### Dynamic Frameworks (Default)

Dynamic frameworks are the default behavior. You can omit the `type` attribute:

```starlark
remote_xcframework.xcframework(
    name = "MyDynamicFramework",
    url = "https://my.server.com/path/to/MyDynamicFramework.xcframework.zip",
    sha256 = "...",
    strip_prefix = "MyDynamicFramework-1.0.0",
)
```

Or explicitly specify `type = "dynamic"`:

```starlark
remote_xcframework.xcframework(
    name = "MyDynamicFramework",
    url = "https://my.server.com/path/to/MyDynamicFramework.xcframework.zip",
    sha256 = "...",
    strip_prefix = "MyDynamicFramework-1.0.0",
    type = "dynamic",
)
```

### Static Frameworks

For static XCFrameworks, set `type = "static"`:

```starlark
remote_xcframework.xcframework(
    name = "MyStaticFramework",
    url = "https://my.server.com/path/to/MyStaticFramework.xcframework.zip",
    sha256 = "...",
    strip_prefix = "MyStaticFramework-1.0.0",
    type = "static",
)
```

**When to use static vs dynamic frameworks:**
- **Static frameworks**: Linked at compile time, increase app size but may improve launch time. Best for frameworks that don't need to be shared across multiple targets.
- **Dynamic frameworks**: Linked at runtime, can be shared across app extensions and the main app. Required for frameworks that need to be loaded dynamically.
