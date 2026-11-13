#!/usr/bin/env python3
"""Reject local data and non-Android platform files in this Android repository.

Uses the index plus current files so it also works before a cleanup is committed.
Only paths/rule names are printed; file contents and secret values are never logged.
"""

from pathlib import Path, PurePosixPath
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
FORBIDDEN_DIRS = {
    '.dart_tool', '.gradle', '.kotlin', '.local-archive', '.autonomous-upgrade', 'build',
}
FORBIDDEN_ROOT_DIRS = {'dist', 'ios', 'macos', 'windows', 'web', 'linux'}
FORBIDDEN_SUFFIXES = {'.apk', '.aab', '.ipa', '.jks', '.keystore', '.p12', '.pfx', '.log', '.bak', '.tmp'}
FORBIDDEN_NAMES = {'key.properties', 'local.properties', '1.2.1', 'ui.xml', 'final_list.png', 'final_list2.png', 'guest_try2.png'}
SECRET_PATTERNS = {
    'github-token': re.compile(rb'\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,})'),
    'private-key': re.compile(rb'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----'),
}


def main():
    result = subprocess.run(
        ['git', 'ls-files', '--cached', '-z'], cwd=ROOT,
        check=True, capture_output=True,
    )
    paths = result.stdout.decode('utf-8').split('\0')
    violations = []
    count = 0
    for name in paths:
        if not name:
            continue
        relative = PurePosixPath(name)
        file = ROOT / name
        # An unstaged deletion is already absent from the proposed working tree.
        if not file.exists():
            continue
        count += 1
        env_file = relative.name == '.env' or (
            relative.name.startswith('.env.') and relative.name != '.env.example'
        )
        if (any(part in FORBIDDEN_DIRS for part in relative.parts[:-1])
                or relative.parts[0] in FORBIDDEN_ROOT_DIRS
                or relative.suffix.lower() in FORBIDDEN_SUFFIXES
                or relative.name in FORBIDDEN_NAMES or env_file
                or name == 'build_unsigned_ipa.sh'
                or name == '.github/workflows/build_ios.yml'):
            violations.append((name, 'local-data-or-unsupported-platform'))
        if file.is_file() and relative.suffix in {'.dart', '.gradle', '.yaml', '.yml', '.json', '.md', '.properties', '.txt'}:
            data = file.read_bytes()
            for rule, pattern in SECRET_PATTERNS.items():
                if pattern.search(data):
                    violations.append((name, rule))
    if violations:
        for name, rule in violations:
            print(f'FAIL: {name} [{rule}]', file=sys.stderr)
        return 1
    print(f'PASS: {count} indexed files checked; no forbidden local/platform paths or credential patterns.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
