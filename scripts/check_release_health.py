#!/usr/bin/env python3
"""Check real public release metadata and bounded download links; never publish."""
import json
import subprocess
import urllib.request
import re

REPOSITORY = 'yuchen0x1/LINUX-DO'


def main():
    release = json.loads(subprocess.check_output(['gh', 'api', f'repos/{REPOSITORY}/releases/latest']))
    assert not release['draft'] and not release['prerelease'], 'Not a stable release'
    version = release['tag_name'].removeprefix('v')
    for abi in ('arm64-v8a', 'armeabi-v7a', 'x86_64'):
        assets = [a for a in release['assets'] if a['name'] == f'linux_do_android_release_{version}_{abi}.apk']
        assert len(assets) == 1, f'Missing or ambiguous {abi} APK'
        asset = assets[0]
        assert asset['size'] > 0 and re.fullmatch(r'sha256:[a-f0-9]{64}', asset.get('digest') or ''), 'Missing digest'
        expected = f'https://github.com/{REPOSITORY}/releases/download/{release["tag_name"]}/{asset["name"]}'
        assert asset['browser_download_url'] == expected, 'Unexpected release origin'
        request = urllib.request.Request(expected, method='HEAD', headers={'User-Agent': 'LINUX-DO-release-health'})
        with urllib.request.urlopen(request, timeout=45) as response:
            assert response.status == 200, 'Download link not accessible'
        print(f'PASS: {asset["name"]} metadata, digest and HTTPS download link')
    assert any(a['name'].startswith('SHA256SUMS') for a in release['assets']), 'Missing checksum file'
    print(f'PASS: {release["tag_name"]}; HEAD requests only, not an installation or full-byte download test')


if __name__ == '__main__':
    main()
