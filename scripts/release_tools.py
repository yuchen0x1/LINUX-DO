#!/usr/bin/env python3
"""Version and signed-asset gates shared by maintainers and tag workflows."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
CERTIFICATE = '4b0e72061c8d08da00cf99f8bc3e6df730530965f9b1c8ba9803a66e28bdd517'
ABIS = ('arm64-v8a', 'armeabi-v7a', 'x86_64')


def version():
    match = re.search(r'^version: (\d+\.\d+\.\d+)\+(\d+)\s*$',
                      (ROOT / 'pubspec.yaml').read_text(encoding='utf-8'), re.M)
    if not match:
        raise ValueError('pubspec.yaml must contain SemVer+integer build number')
    return match.group(1), int(match.group(2))


def notes(tag):
    standalone = ROOT / f'docs/releases/release-notes-{tag}.md'
    if standalone.exists():
        text = standalone.read_text(encoding='utf-8').strip()
        if not text:
            raise ValueError(f'No release notes for {tag}')
        if text.splitlines()[0] != '## 📢 版本概述':
            raise ValueError(f'{standalone.name} must start with "## 📢 版本概述"')
        return text + '\n'
    text = (ROOT / 'docs/releases/release-notes.md').read_text(encoding='utf-8')
    match = re.search(r'^## ' + re.escape(tag) + r'[^\n]*\n(.*?)(?=^## |\Z)', text, re.M | re.S)
    if not match or not match.group(1).strip():
        raise ValueError(f'No release notes for {tag}')
    return match.group(0).strip() + '\n'


def package(apk_dir, output, signer, tag):
    product_version, build = version()
    if tag != 'v' + product_version:
        raise ValueError('Tag does not match source version')
    # Validate everything before writing any release metadata.
    assets = []
    for abi in ABIS:
        path = apk_dir / f'app-{abi}-release.apk'
        result = subprocess.run([str(signer), 'verify', '--verbose', '--print-certs', str(path)],
                                check=True, capture_output=True, text=True)
        certificates = re.findall(r'^Signer #\d+ certificate SHA-256 digest: ([a-fA-F0-9]+)$',
                                  result.stdout, re.M)
        if [c.lower() for c in certificates] != [CERTIFICATE]:
            raise ValueError(f'{abi}: signing certificate differs from existing releases')
        assets.append((abi, path, hashlib.sha256(path.read_bytes()).hexdigest()))
    output.mkdir(parents=True, exist_ok=True)
    metadata = dict(schema_version=1, version=product_version, build_number=build,
                    platform='android', min_sdk=23, mandatory=False,
                    certificate_sha256=CERTIFICATE, assets=[])
    sums = []
    for abi, path, digest in assets:
        name = f'linux_do_android_release_{product_version}_{abi}.apk'
        (output / name).write_bytes(path.read_bytes())
        sums.append(f'{digest}  {name}')
        metadata['assets'].append(dict(abi=abi, name=name, size=path.stat().st_size,
            sha256=digest, url=f'https://github.com/yuchen0x1/LINUX-DO/releases/download/{tag}/{name}'))
    (output / f'SHA256SUMS-{tag}.txt').write_text('\n'.join(sums) + '\n', encoding='utf-8')
    (output / 'android-update.json').write_text(json.dumps(metadata, indent=2) + '\n', encoding='utf-8')
    (output / f'release-notes-{tag}.md').write_text(notes(tag), encoding='utf-8')
    # GPL standalone core notice and exact corresponding-source pointer.
    lock = json.loads((ROOT / 'android/network-core.lock.json').read_text(encoding='utf-8'))
    (output / 'network-core-NOTICE.txt').write_text(
        (ROOT / 'assets/licenses/network-core-NOTICE.txt').read_text(encoding='utf-8') +
        f'\nExact source: {lock["repository"]}/tree/{lock["commit"]}\n', encoding='utf-8')
    print(f'PASS: {tag}; three existing-certificate APKs, checksums, metadata, notices')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('command', choices=['version', 'package'])
    parser.add_argument('--tag')
    parser.add_argument('--apk-dir', type=Path, default=ROOT / 'build/app/outputs/flutter-apk')
    parser.add_argument('--output', type=Path, default=ROOT / 'dist/release')
    parser.add_argument('--apksigner', type=Path)
    args = parser.parse_args()
    current, build = version()
    if args.tag and args.tag != 'v' + current:
        parser.error('Tag and source version differ')
    if args.command == 'version':
        if args.tag:
            notes(args.tag)
        print(f'{current}+{build}')
    elif not args.apksigner or not args.tag:
        parser.error('package requires --tag and --apksigner')
    else:
        package(args.apk_dir, args.output, args.apksigner, args.tag)


if __name__ == '__main__':
    main()
