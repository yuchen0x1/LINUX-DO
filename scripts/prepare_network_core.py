#!/usr/bin/env python3
"""Fetch pinned upstream Android executables; generated files stay in build/."""
import concurrent.futures
import gzip
import hashlib
import json
from pathlib import Path
import shutil
import time
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
LOCK = json.loads((ROOT / 'android/network-core.lock.json').read_text())
OUT = ROOT / 'build/app/network-core'


def prepare(item):
    abi, artifact = item
    name = f"mihomo-android-{artifact['arch']}-v{LOCK['version']}.gz"
    compressed = OUT / 'downloads' / name
    compressed.parent.mkdir(parents=True, exist_ok=True)
    for attempt in range(3):
        try:
            if not compressed.exists() or hashlib.sha256(compressed.read_bytes()).hexdigest() != artifact['sha256']:
                url = f"{LOCK['repository']}/releases/download/v{LOCK['version']}/{name}"
                request = urllib.request.Request(url, headers={'User-Agent': 'LINUX-DO-Android-build'})
                temporary = compressed.with_suffix('.download')
                with urllib.request.urlopen(request, timeout=40) as source, temporary.open('wb') as target:
                    total = 0
                    while True:
                        data = source.read(256 * 1024)
                        if not data:
                            break
                        total += len(data)
                        if total > 32 * 1024 * 1024:
                            raise ValueError('Core archive exceeds size limit')
                        target.write(data)
                if hashlib.sha256(temporary.read_bytes()).hexdigest() != artifact['sha256']:
                    raise ValueError(f'Core SHA-256 mismatch for {abi}')
                temporary.replace(compressed)
            binary = OUT / 'jniLibs' / abi / 'liblinuxdo_proxy.so'
            binary.parent.mkdir(parents=True, exist_ok=True)
            # Packaged in nativeLibraryDir to comply with Android's no-exec app-data policy.
            with gzip.open(compressed, 'rb') as source, binary.open('wb') as target:
                shutil.copyfileobj(source, target)
            if not 0 < binary.stat().st_size <= 128 * 1024 * 1024:
                raise ValueError('Invalid core binary size')
            print(f'PASS: verified network core {LOCK["version"]} / {abi}', flush=True)
            return
        except Exception:
            if attempt == 2:
                raise
            time.sleep(attempt + 1)


if __name__ == '__main__':
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        list(pool.map(prepare, LOCK['artifacts'].items()))
