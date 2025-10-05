import re
import sys

def update_module_bazel(version):
    with open('MODULE.bazel', 'r') as f:
        content = f.read()

    new_module_content = f'''module(
    name = "rules_apple_remote_xcframework",
    version = "{version}",
    bazel_compatibility = [">=7.0.0"],
    compatibility_level = 1,
)'''

    content = re.sub(r'module\((.*?)\)', new_module_content, content, flags=re.DOTALL)

    with open('MODULE.bazel', 'w') as f:
        f.write(content)

if __name__ == '__main__':
    update_module_bazel(sys.argv[1])
