"""A module extension for importing remote or local XCFrameworks as Bazel dependencies."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _build_file_content(target_name, import_rule):
    return """
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

def _local_xcframework_repository_impl(repository_ctx):
    path = repository_ctx.attr.path

    if path.endswith(".xcframework"):
        repository_ctx.symlink(path, path.split("/")[-1])
    else:
        repository_ctx.extract(
            archive = repository_ctx.path(path),
            stripPrefix = repository_ctx.attr.strip_prefix,
        )

    repository_ctx.file("BUILD.bazel", repository_ctx.attr.build_file_content)

local_xcframework_repository = repository_rule(
    implementation = _local_xcframework_repository_impl,
    attrs = {
        "path": attr.string(mandatory = True),
        "strip_prefix": attr.string(),
        "build_file_content": attr.string(mandatory = True),
    },
)

def _remote_xcframework_impl(ctx):
    for module in ctx.modules:
        for xcframework in module.tags.xcframework:
            target_name = xcframework.name
            framework_type = xcframework.type
            path = xcframework.path
            url = xcframework.url
            sha256 = xcframework.sha256

            if bool(url) == bool(path):
                fail("xcframework '{name}' must set exactly one of 'url' or 'path'.".format(name = target_name))

            if path and not path.startswith("/"):
                fail("xcframework '{name}' path must be an absolute filesystem path: {path}".format(
                    name = target_name,
                    path = path,
                ))

            if path and sha256:
                fail("xcframework '{name}' must not set 'sha256' when using a local 'path'.".format(name = target_name))

            if url and not sha256:
                fail("xcframework '{name}' must set 'sha256' when using 'url'.".format(name = target_name))

            if framework_type == "static":
                import_rule = "apple_static_xcframework_import"
            else:
                import_rule = "apple_dynamic_xcframework_import"

            build_file_content = _build_file_content(target_name, import_rule)

            if path:
                local_xcframework_repository(
                    name = xcframework.name,
                    build_file_content = build_file_content,
                    path = path,
                    strip_prefix = xcframework.strip_prefix,
                )
            else:
                http_archive(
                    name = xcframework.name,
                    build_file_content = build_file_content,
                    sha256 = sha256,
                    strip_prefix = xcframework.strip_prefix,
                    urls = [url],
                )

xcframework_tag = tag_class(
    attrs = {
        "name": attr.string(mandatory = True, doc = "A unique name for the repository."),
        "url": attr.string(doc = "The URL of the archive containing the XCFramework."),
        "path": attr.string(doc = "An absolute filesystem path to a local XCFramework archive or .xcframework directory."),
        "sha256": attr.string(doc = "The SHA256 checksum of the remote archive. Required when 'url' is set."),
        "strip_prefix": attr.string(doc = "A directory prefix to strip from the archive."),
        "type": attr.string(
            default = "dynamic",
            values = ["static", "dynamic"],
            doc = "Framework type: 'static' for static frameworks, 'dynamic' for dynamic frameworks (default).",
        ),
    },
    doc = "Declares a single XCFramework from either a remote URL or a local absolute path.",
)

remote_xcframework_extension = module_extension(
    implementation = _remote_xcframework_impl,
    tag_classes = {"xcframework": xcframework_tag},
)
