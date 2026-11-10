# -*- coding: utf-8 -*-
"""把 5 张大图转为 WebP 并限制最大宽度，保留原文件到 git 历史。

用法: python -I scripts_tmp/optimize_assets.py
"""
import os
import sys

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

# (原相对路径, 最大宽度, 质量)
TARGETS = [
    ('assets/images/profile-header-bg.png', 1440, 80),
    ('assets/images/light/search-banner.png', 1440, 82),
    ('assets/images/dark/search-banner.png', 1440, 82),
    ('assets/images/light/chat-backgroud.png', 1080, 80),
    ('assets/images/dark/chat-backgroud.png', 1080, 80),
    ('assets/images/light/chat-list-background.png', 1080, 80),
    ('assets/images/dark/chat-list-background.png', 1080, 80),
]


def convert(rel, max_w, quality):
    src = os.path.join(ROOT, rel)
    if not os.path.exists(src):
        print('SKIP missing:', rel)
        return 0, 0
    dst = os.path.splitext(src)[0] + '.webp'
    before = os.path.getsize(src)

    im = Image.open(src)
    # 保留 alpha 通道
    if im.mode not in ('RGB', 'RGBA'):
        im = im.convert('RGBA')
    if im.width > max_w:
        h = round(im.height * max_w / im.width)
        im = im.resize((max_w, h), Image.LANCZOS)

    im.save(dst, 'WEBP', quality=quality, method=6)
    after = os.path.getsize(dst)
    print('%-52s %5dKB -> %4dKB  %dx%d' % (
        rel, before // 1024, after // 1024, im.width, im.height))
    return before, after


def main():
    total_b = total_a = 0
    for rel, w, q in TARGETS:
        b, a = convert(rel, w, q)
        total_b += b
        total_a += a
    print('-' * 70)
    print('合计 %dKB -> %dKB，节省 %dKB (%.1f%%)' % (
        total_b // 1024, total_a // 1024, (total_b - total_a) // 1024,
        100.0 * (total_b - total_a) / total_b if total_b else 0))


if __name__ == '__main__':
    sys.exit(main())
