# ai-agent-config-share

一份可分享的 Claude Code commands + references 子集，主要用于 spec / plan / skill 工作流。

## 内容

- `claude/commands/custom/` — 9 个 slash commands（spec / plan / skill 的创建与审查、handoff、UX 模拟测试）
- `claude/references/` — 被 commands 引用的原则 / 模式 / 协议文档
- `claude/CLAUDE.md` + `codex/AGENTS.md` — Claude Code / Codex CLI 通用行为指引（需手动 merge，见安装第 3 步）

完整 command 列表 + 常见开发阶段的工作流组合 见 [command-guide.md](command-guide.md)。

## 安装

1. **克隆到稳定路径**（installer 创建 symlink 指向仓库内文件，仓库不能移动 / 删除）：

```sh
git clone git@github.com:Picnic-PGC/dongs-agent-config.git .
cd ai-agent-config-share
```

2. **运行 installer**：

```sh
./install.sh
```

3. **手动 merge 顶层 config**：installer 末尾打印一段 prompt——粘到 Claude Code，由它把 `claude/CLAUDE.md` / `codex/AGENTS.md` 中的新内容并入你已有的 `~/.claude/CLAUDE.md` / `~/.codex/AGENTS.md`，保留你已有的自定义内容。

## 用法

装完后在 Claude Code 中输入 `/custom:` 触发 slash command 选择器。

