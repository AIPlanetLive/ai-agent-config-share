# ai-agent-config-share

Claude Code 和 Codex CLI 的共享 agent 配置，包括 slash commands、行为指引、agent 定义和浏览器自动化 skill。安装脚本自动处理 symlink 和配置合并。

## 文档导航

| 想知道 | 看这里 |
|---|---|
| 为什么这套命令长成这个样子 | [docs/philosophy.md](docs/philosophy.md) |
| 有哪些命令、什么场景用、怎么组合 | [docs/command-guide.md](docs/command-guide.md) |

## 安装

1. **克隆到稳定路径**（installer 用 symlink 指向仓库内文件，仓库不能移动 / 删除）：

```sh
git clone git@github.com:Picnic-PGC/dongs-agent-config.git
```

2. **复制下面的 prompt 粘贴到 Claude Code 执行**（会运行 install.sh 安装 symlink、agent 定义和 MCP server 依赖，然后合并配置文件）：

```
帮我把这个仓库的 AI agent 配置安装到我的用户目录。

仓库路径是当前目录。先跑 ./install.sh，它会处理 symlink、codex agent 定义和 MCP server CLI 工具的安装。

然后需要合并配置文件：
- claude/CLAUDE.md → 合入 ~/.claude/CLAUDE.md
- codex/AGENTS.md → 合入 ~/.codex/AGENTS.md
- codex/config.toml → 合入 ~/.codex/config.toml

合并规则：保留我已有的内容，只补入仓库里有但我没有的部分。如果有同名但内容不同的 key 或 section，先给我看 diff 让我决定。

如果 install.sh 提示 GITHUB_PERSONAL_ACCESS_TOKEN 没设置，帮我确认一下环境变量配置。
```

## 用法

装完后在 Claude Code 中输入 `/custom:` 触发 slash command 选择器。具体工作流组合见 [docs/command-guide.md](docs/command-guide.md)。
