# Memos for TerraMaster TOS 7

TOS 7 App Center package for [Memos](https://www.usememos.com) — a lightweight, self-hosted memo hub.

一个把 [Memos](https://www.usememos.com) 打包上架到 TOS 7 应用中心的 Docker 应用（单容器、单数据卷、SQLite，零外部依赖）。

---

## What it does / 这是什么

Memos is a privacy-first, lightweight note-taking service. It runs entirely inside a Docker container on your TNAS, so all notes stay on your own device.

- Markdown notes with tags, search and sharing
- Single SQLite file — trivial to back up
- Web UI on port `10001` (host) → container `5230`
- No external database, no root, no privileged mode

## Package contents / 包内文件

```
memos.tar.gz
├── config.ini            # TOS application metadata
├── memos.lang            # 14 languages (zh-cn, zh-hk, en-us, ... pt-pt)
├── memos.svg             # application icon (SVG, transparent, 527 B)
└── docker-compose.yml    # container definition
```

## docker-compose.yml

```yaml
version: "3.8"

services:
  memos:
    image: neosmemo/memos:0.31
    restart: unless-stopped
    user: "1000:1000"
    ports:
      - "10001:5230"
    volumes:
      - ./data:/var/opt/memos
    environment:
      - TZ=Asia/Shanghai
    healthcheck:
      test: ["CMD-SHELL", "(command -v curl >/dev/null && curl -fsS http://localhost:5230/) || (command -v wget >/dev/null && wget -q -O /dev/null http://localhost:5230/) || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3

x-app-meta:
  web:
    port: 10001
    protocol: http
```

## Data location / 数据位置

The host side of `./data` is resolved by the platform to the application data root:

```
/Volume<N>/DockerAppData/memos/data
```

Data survives uninstall as long as "delete data" is not selected; it also survives reinstall.

## Build

```bash
./build.sh            # produces memos.tar.gz + memos.tar.gz.sha256
```

The archive must contain the four files at its root:

```bash
tar -czf memos.tar.gz config.ini memos.lang memos.svg docker-compose.yml
sha256sum memos.tar.gz > memos.tar.gz.sha256
```

## Release

The package is published as a Release asset (the TOS Developer Platform downloads it from the Release, not from the repository root):

- Tag: `1.0.3`
- Asset: `memos.tar.gz`
- Checksum: `memos.tar.gz.sha256`

## Compliance notes / 合规说明

- Image source: Docker Hub only (`neosmemo/memos`), version tag pinned, never `:latest`.
- Runs as a non-root user (`user: "1000:1000"`); no `privileged`, no `network_mode: host`.
- `container_name` is intentionally **omitted**: Compose then derives a globally unique name (`<project>_<service>_1`), so the application never fails to install because the device already runs a container called `memos`. The TOS platform only appends a numeric suffix to a conflicting *project* name — it does not rewrite `container_name` — so hard-coding a container name is a portability risk.
- The icon in this repository is original placeholder artwork created for this package; it is **not** the upstream project logo, to avoid trademark issues.
- This repository contains packaging metadata only. The application itself is developed by the Memos project and distributed under its own license (MIT). All credit belongs to the upstream authors.
- No credentials, tokens or secrets are stored in this repository.

## Links

- Upstream project: https://github.com/usememos/memos
- Docker Hub image: https://hub.docker.com/r/neosmemo/memos
- TOS 7 development guide: https://github.com/terramaster-tos/tos-app-pkg-tools
