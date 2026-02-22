"""A module extension for importing remote XCFrameworks as Bazel dependencies."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _remote_xcframework_impl(ctx):
    for module in ctx.modules:
        for xcframework in module.tags.xcframework:
            target_name = xcframework.name
            framework_type = xcframework.type
            
            if framework_type == "static":
                import_rule = "apple_static_xcframework_import"
            else:
                import_rule = "apple_dynamic_xcframework_import"
            
            build_file_content = """
load("@rules_apple//apple:apple.bzl", "{import_rule}")

{import_rule}(
    name = "{target_name}",
    visibility = ["//visibility:public"],
    xcframework_imports = glob(["**/*.xcframework/**"]),
)
            """.format(
                target_name = target_name,
                import_rule = import_rule,
            )

            http_archive(
                name = xcframework.name,
                build_file_content = build_file_content,
                sha256 = xcframework.sha256,
                strip_prefix = xcframework.strip_prefix,
                urls = [xcframework.url],
            )

xcframework_tag = tag_class(
    attrs = {
        "name": attr.string(mandatory = True, doc = "A unique name for the repository."),
        "url": attr.string(mandatory = True, doc = "The URL of the .zip archive containing the XCFramework."),
        "sha256": attr.string(mandatory = True, doc = "The SHA256 checksum of the archive."),
        "strip_prefix": attr.string(doc = "A directory prefix to strip from the archive."),
        "type": attr.string(
            default = "dynamic",
            values = ["static", "dynamic"],
            doc = "Framework type: 'static' for static frameworks, 'dynamic' for dynamic frameworks (default).",
        ),
    },
    doc = "Declares a single remote XCFramework to be downloaded.",
)

remote_xcframework_extension = module_extension(
    implementation = _remote_xcframework_impl,
    tag_classes = {"xcframework": xcframework_tag},
)