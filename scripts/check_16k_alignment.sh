#!/usr/bin/env bash
# 校验 APK 内 native 库的 LOAD 段是否按 16KB 页对齐。
#
# Android 15 起 64 位设备开始使用 16KB 内存页，ELF 的 LOAD 对齐小于 0x4000 会
# 导致 dlopen 失败、应用启动即崩溃。Google Play 对 64 位 ABI 有此要求。
#
# 注意：32 位 ABI（armeabi-v7a）**不适用** 16KB 页要求，对其只告警不失败，
# 否则会产生假警报。
#
# 用法：scripts/check_16k_alignment.sh <apk> [readelf]
# 退出码：0 全部合规；1 存在未对齐的 64 位库；2 环境缺失

set -euo pipefail

APK="${1:-}"
if [[ -z "$APK" || ! -f "$APK" ]]; then
  echo "用法: $0 <apk> [readelf]" >&2
  exit 2
fi

READELF="${2:-}"
if [[ -z "$READELF" ]]; then
  for candidate in \
    "${ANDROID_NDK_HOME:-}/toolchains/llvm/prebuilt/"*/bin/llvm-readelf \
    "${ANDROID_HOME:-}/ndk/"*/toolchains/llvm/prebuilt/*/bin/llvm-readelf \
    "$(command -v llvm-readelf || true)" \
    "$(command -v readelf || true)"
  do
    if [[ -x "$candidate" ]]; then READELF="$candidate"; break; fi
  done
fi

if [[ -z "$READELF" || ! -x "$READELF" ]]; then
  echo "未找到 llvm-readelf / readelf，跳过 16KB 对齐检查" >&2
  exit 2
fi

# 16KB 页要求 ELF LOAD 段 align >= 0x4000
MIN_ALIGN=16384

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

unzip -q -o "$APK" 'lib/arm64-v8a/*.so' 'lib/armeabi-v7a/*.so' -d "$TMPDIR" 2>/dev/null || true

if ! find "$TMPDIR" -name '*.so' -print -quit | grep -q .; then
  echo "APK 内没有 native 库，无需检查" >&2
  exit 0
fi

fail=0
while IFS= read -r so; do
  # 取所有 LOAD 段 p_align 的最小值
  min=$( "$READELF" -lW "$so" \
    | awk '$1=="LOAD" {print $NF}' \
    | while read -r a; do printf '%d\n' "$a"; done \
    | sort -n | head -1 )

  [[ -z "$min" ]] && continue

  rel="${so#"$TMPDIR"/}"
  if (( min < MIN_ALIGN )); then
    # 仅 64 位 ABI 会因未对齐而加载失败；32 位只提示
    if [[ "$rel" == lib/arm64-v8a/* ]]; then
      printf 'FAIL  %-44s LOAD align=%s (< 16384)\n' "$rel" "$(printf '0x%x' "$min")"
      fail=1
    else
      printf 'WARN  %-44s LOAD align=%s（32 位 ABI，不受 16KB 页要求约束）\n' "$rel" "$(printf '0x%x' "$min")"
    fi
  else
    printf 'OK    %-44s LOAD align=%s\n' "$rel" "$(printf '0x%x' "$min")"
  fi
done < <(find "$TMPDIR" -name '*.so' | sort)

if (( fail )); then
  echo "" >&2
  echo "存在未按 16KB 页对齐的 64 位 native 库，在 16KB 页设备上会启动失败。" >&2
  echo "请升级提供该库的插件（常见为 MLKit / CameraX / jni）。" >&2
  exit 1
fi

echo ""
echo "所有 native 库均满足 16KB 页对齐。"
