# Ictye Neovim Configuration — Tutorial Series

This 10-part tutorial series guides you through the ictye-nvim-cfg, a modular, dual-mode Neovim configuration designed for developers seeking a powerful yet maintainable editing environment. Whether you've just installed the config or want to understand its internals to customize it to your needs, this series covers everything from first launch to extending the architecture yourself.

Each tutorial builds on the previous ones, so you can follow along sequentially or jump to the chapters that interest you most. All tutorials assume you have the configuration installed and running.

## Tutorial Overview

| # | Title | Level | Description |
|---|-------|-------|-------------|
| 01 | Quickstart | Beginner | First steps after installation — launching Neovim, understanding full vs lite mode, installing LSP servers via Mason, and verifying your setup with `:checkhealth`. |
| 02 | File Navigation & Project Management | Beginner | Navigating the filesystem with Neotree and Telescope, managing buffers effectively, and using sessions to pick up where you left off. |
| 03 | Efficient Editing | Beginner → Intermediate | Speed up your editing workflow with Flash jump, multicursor editing, UFO fold controls, rip-substitute, and hydra-based window management. |
| 04 | Git Workflow | Intermediate | Using LazyGit for visual git operations, Gitsigns for inline blame and hunks, jj (Jujutsu) integration for commit management, and GitHub issue tracking from the editor. |
| 05 | LSP & Code Intelligence | Intermediate | Language server setup via Mason, autocompletion with blink.cmp, navigating diagnostics with Trouble, and using code actions and refactoring tools. |
| 06 | Debugging & Testing | Intermediate → Advanced | Configuring DAP (Debug Adapter Protocol) for multiple languages, running and debugging tests with neotest, and managing background tasks with Overseer. |
| 07 | AI-Assisted Development | Intermediate | Integrating AI into your workflow with OpenCode for inline chat and code actions, Avante for multi-provider AI assistance, and MCP (Model Context Protocol) for file-aware tooling. |
| 08 | Customizing Your Config | Advanced | Changing themes, remapping keys, adding or removing plugins, and tweaking LSP settings — all without breaking the existing architecture. |
| 09 | Performance Tuning | Advanced | Understanding Lite mode for faster startup, profiling startup time, optimizing lazy loading, and diagnosing slow plugins. |
| 10 | Deep Architecture & Extension | Advanced | The full initialization flow (`init.lua` → `full_init.lua` / `lite_init.lua`), how the plugin system works, and adding support for new languages and tools. |

## Recommended Reading Order

The series is organized into three tiers:

**Getting Started (01–03):** Start here if you're new to the configuration. These tutorials cover the essentials: launching Neovim, navigating files, and editing efficiently. You'll be productive after the first three chapters.

**Daily Workflow (04–07):** Once you're comfortable with the basics, dive into git operations, LSP-powered code intelligence, debugging, and AI integration. These chapters cover the tools you'll use every day.

**Power User (08–10):** For users who want to take full control. Learn how to customize the config to your preferences, diagnose and fix performance issues, and understand the architecture well enough to extend it.

If you're short on time, start with **01** (Quickstart) and **05** (LSP & Code Intelligence) — they give you the biggest productivity boost with the least effort.

## Additional Resources

- [README.md](../README.md) — Overview, features, installation, and keymaps
- [DEVELOP.md](../DEVELOP.md) — Development guide and dependency setup (English)
- [DEVELOP_zh.md](../DEVELOP_zh.md) — Development guide and dependency setup (Chinese)
- [FEATURES.md](../FEATURES.md) — Detailed feature walkthrough (English)
- [FEATURES_zh.md](../FEATURES_zh.md) — Detailed feature walkthrough (Chinese)
