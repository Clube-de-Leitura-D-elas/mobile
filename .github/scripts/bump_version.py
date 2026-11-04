#!/usr/bin/env python3
import sys
import re
import os

def bump_version(pubspec_path="pubspec.yaml", bump_type="build_number"):
    if not os.path.exists(pubspec_path):
        raise FileNotFoundError(f"Arquivo não encontrado: {pubspec_path}")

    with open(pubspec_path, "r", encoding="utf-8") as f:
        content = f.read()

    pattern = r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)"
    match = re.search(pattern, content, re.MULTILINE)
    if not match:
        raise ValueError("Formato de versão em pubspec.yaml não suportado. Esperado: major.minor.patch+build (ex: 0.1.0+4)")

    major, minor, patch, build = map(int, match.groups())
    old_version = f"{major}.{minor}.{patch}+{build}"

    if bump_type == "patch":
        patch += 1
        build += 1
    elif bump_type == "minor":
        minor += 1
        patch = 0
        build += 1
    elif bump_type == "major":
        major += 1
        minor = 0
        patch = 0
        build += 1
    elif bump_type == "none":
        pass
    else:  # "build_number" default
        build += 1

    new_version = f"{major}.{minor}.{patch}+{build}"
    version_name = f"{major}.{minor}.{patch}"

    if old_version != new_version:
        new_content = re.sub(pattern, f"version: {new_version}", content, flags=re.MULTILINE)
        with open(pubspec_path, "w", encoding="utf-8") as f:
            f.write(new_content)

    print(f"Versão anterior: {old_version}")
    print(f"Nova versão:     {new_version}")

    github_output = os.getenv("GITHUB_OUTPUT")
    if github_output:
        with open(github_output, "a", encoding="utf-8") as f:
            f.write(f"new_version={new_version}\n")
            f.write(f"version_name={version_name}\n")
            f.write(f"build_number={build}\n")
            f.write(f"old_version={old_version}\n")

if __name__ == "__main__":
    b_type = sys.argv[1] if len(sys.argv) > 1 else "build_number"
    target_file = sys.argv[2] if len(sys.argv) > 2 else "pubspec.yaml"
    bump_version(target_file, b_type)
