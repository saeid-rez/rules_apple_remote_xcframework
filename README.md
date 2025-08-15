# rules_apple_remote_xcframework

A Bazel module for consuming remote XCFrameworks for iOS/MacOS applications.

## Installation

Add the following to your `MODULE.bazel` file:

```starlark
bazel_dep(name = "rules_apple_remote_xcframework", version = "0.4.6")

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