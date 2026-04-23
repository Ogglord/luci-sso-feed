# openwrt-aarch64-feed

Custom OpenWrt package feed for `aarch64_cortex-a53` (GL.iNet Flint 2 / MT6000, Cudy WR3000, etc.).

Packages are built automatically from source and published to GitHub Pages.

## Packages

| Package | Description |
|---------|-------------|
| `luci-sso` | OIDC/OAuth2 SSO for LuCI |
| `luci-sso-crypto-openssl` | OpenSSL crypto backend (required) |

## Install on router

```sh
# Trust the feed's signing key
wget -O /etc/apk/keys/luci-sso-feed.pub \
  https://ogglord.github.io/openwrt-aarch64-feed/keys/luci-sso-feed.pub

# Add feed
echo "https://ogglord.github.io/openwrt-aarch64-feed/packages/aarch64_cortex-a53/luci_sso" \
  >> /etc/apk/repositories

apk update
apk add luci-sso luci-sso-crypto-openssl
```

## Adding packages

1. Add submodule: `git submodule add <url> <name>`
2. Enable in `build-feed.yml`: add `CONFIG_PACKAGE_<name>=m` to the config block
