# openwrt-aarch64-feed

Custom OpenWrt package feed for `aarch64_cortex-a53` (GL.iNet Flint 2 / MT6000, Cudy WR3000, etc.).

Packages are built automatically from the OpenWrt SNAPSHOT SDK and published to GitHub Pages.

## Packages

| Package | Description |
|---------|-------------|
| `luci-sso` | OIDC/OAuth2 SSO for LuCI |
| `luci-sso-crypto-mbedtls` | mbedTLS crypto backend — vanilla OpenWrt SNAPSHOT |
| `luci-sso-crypto-openssl` | OpenSSL crypto backend — pesa1234 custom firmware |
| `luci-sso-crypto-wolfssl` | WolfSSL crypto backend |

`luci-sso` requires exactly one crypto backend. Pick the one matching your firmware's SSL library.

## Install on router

### Step 1 — trust the signing key

```sh
wget -O /etc/apk/keys/luci-sso-feed.pub \
  https://ogglord.github.io/openwrt-aarch64-feed/keys/luci-sso-feed.pub
```

### Step 2 — add the feed

```sh
echo "https://ogglord.github.io/openwrt-aarch64-feed/packages/aarch64_cortex-a53/luci_sso" \
  >> /etc/apk/repositories.d/customfeeds.list
apk update
```

### Step 3 — install

**pesa1234 custom firmware (MT6000):**
```sh
apk add luci-sso luci-sso-crypto-openssl
```

**Vanilla OpenWrt SNAPSHOT:**
```sh
apk add luci-sso luci-sso-crypto-mbedtls
```

## Adding packages

1. Add submodule: `git submodule add <url> <name>`
2. Enable in `build-feed.yml`: add `CONFIG_PACKAGE_<name>=m` to the config block
