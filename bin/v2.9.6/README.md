# 内置 realm 二进制（v2.9.6）

本目录存放 [zhboner/realm](https://github.com/zhboner/realm) v2.9.6 的官方发布包，
供中国大陆网络在无法直连 GitHub Release 时使用。

- 文件为官方 `realm-<arch>.tar.gz` 的 Base64 编码（`.b64`），解码后与官方原包逐字节一致。
- `SHA256SUMS` 中的哈希与 GitHub 官方 Release 资产摘要（digest）一致，可自行核对：
  解码后执行 `sha256sum realm-<arch>.tar.gz` 并与 `SHA256SUMS` 对照。
- 安装脚本的下载顺序：先从本仓库多源镜像取本目录的内置包并校验 SHA256，
  校验不过或版本不符时，再经加速代理拉取上游 GitHub Release 原包。
- realm 采用 MIT 许可证再分发，许可证原文见 `REALM-LICENSE`（Copyright (c) 2020 zhboner）。

包含架构（与安装脚本实际使用的 musl 静态构建一致）：

| 文件 | 适用 |
|---|---|
| `realm-x86_64-unknown-linux-musl.tar.gz.b64` | x86_64 |
| `realm-aarch64-unknown-linux-musl.tar.gz.b64` | aarch64 / ARM64 |
| `realm-armv7-unknown-linux-musleabihf.tar.gz.b64` | armv7l |
| `realm-arm-unknown-linux-musleabihf.tar.gz.b64` | armv6l |
