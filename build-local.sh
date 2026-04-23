#!/usr/bin/env bash
set -euo pipefail

FEED_DIR="$(cd "$(dirname "$0")" && pwd)"
SDK_ARCHIVE="${SDK_ARCHIVE:-/tmp/openwrt-sdk-mediatek-filogic_gcc-14.3.0_musl.Linux-x86_64.tar.zst}"
# SDK must live OUTSIDE the feed dir to avoid feed scanner filesystem loops
SDK_DIR="${SDK_DIR:-/tmp/openwrt-sdk-filogic}"
OUT_DIR="${FEED_DIR}/dist"

# Extract SDK
if [ ! -d "${SDK_DIR}" ]; then
    if [ ! -f "${SDK_ARCHIVE}" ]; then
        echo "[!] SDK not found: ${SDK_ARCHIVE}"
        echo "    wget -P /tmp/ https://downloads.openwrt.org/snapshots/targets/mediatek/filogic/openwrt-sdk-mediatek-filogic_gcc-14.3.0_musl.Linux-x86_64.tar.zst"
        exit 1
    fi
    echo "[*] Extracting SDK to ${SDK_DIR}..."
    mkdir -p "${SDK_DIR}"
    tar -xf "${SDK_ARCHIVE}" -C "${SDK_DIR}" --strip-components=1
fi

# Configure feeds — update all (base, packages, luci, etc.) + our feed
echo "[*] Updating feeds..."
grep -q "luci_sso" "${SDK_DIR}/feeds.conf.default" 2>/dev/null || \
    echo "src-link luci_sso ${FEED_DIR}" >> "${SDK_DIR}/feeds.conf.default"

(cd "${SDK_DIR}" && \
    ./scripts/feeds update -a && \
    ./scripts/feeds install -a -p luci_sso && \
    ./scripts/feeds install libmbedtls libwolfssl libopenssl libucode ucode \
        ucode-mod-fs ucode-mod-ubus ucode-mod-uci ucode-mod-math \
        ucode-mod-uclient ucode-mod-uloop ucode-mod-log liblucihttp-ucode)

# Build
echo "[*] Building..."
(cd "${SDK_DIR}" && \
    printf 'CONFIG_PACKAGE_luci-sso=m\nCONFIG_PACKAGE_luci-sso-crypto-mbedtls=m\nCONFIG_PACKAGE_luci-sso-crypto-wolfssl=m\nCONFIG_PACKAGE_luci-sso-crypto-openssl=m\n' >> .config && \
    make defconfig && \
    make package/luci-sso/compile -j"$(nproc)" V=s && \
    make package/index)

# Collect
echo "[*] Collecting artifacts..."
mkdir -p "${OUT_DIR}"
cp -r "${SDK_DIR}/bin/packages/aarch64_cortex-a53/luci_sso/." "${OUT_DIR}/"

echo "[*] Done. Packages in ${OUT_DIR}/"
ls -lh "${OUT_DIR}/"*.apk 2>/dev/null || ls -lh "${OUT_DIR}/"*.ipk 2>/dev/null || true
