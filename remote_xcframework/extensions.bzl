load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _remote_xcframework_impl(ctx):
    for module in ctx.modules:
        for xcframework in module.tags.xcframework:
            target_name = xcframework.name
            build_file_content = """
load("@build_bazel_rules_apple//apple:apple.bzl", "apple_dynamic_xcframework_import")

apple_dynamic_xcframework_import(
    name = "{target_name}",
    visibility = ["//visibility:public"],
    xcframework_imports = glob(["**/*.xcframework/**"]),
)
            """.format(target_name = target_name)

            http_archive(
                name = xcframework.name,
                build_file_content = build_file_content,
                sha256 = xcframework.sha256,
                strip_prefix = xcframework.strip_prefix,
                urls = [xcframework.url],
            )

xcframework_tag = tag(
    attrs = {
        "name": attr.string(mandatory = True, doc = "A unique name for the repository."),
        "url": attr.string(mandatory = True, doc = "The URL of the .zip archive containing the XCFramework."),
        "sha256": attr.string(mandatory = True, doc = "The SHA256 checksum of the archive."),
        "strip_prefix": attr.string(doc = "A directory prefix to strip from the archive."),
    },
    doc = "Declares a single remote XCFramework to be downloaded.",
)

remote_xcframework_extension = module_extension(
    implementation = _remote_xcframework_impl,
    tag_classes = {"xcframework": xcframework_tag},
)