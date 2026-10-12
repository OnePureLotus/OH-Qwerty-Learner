# 开发约束

- **仓库路径**：请使用无空格目录 `OH-Qwerty-Learner`（HarmonyOS 编译路径限制）。若仍存在旧目录 `OH Qwerty Learner`，请关闭占用该目录的 IDE/终端后删除，仅保留本目录。
- **修改位置**：所有代码变更、构建命令均在 `OH-Qwerty-Learner` 下进行，不要回到 ArkWeb 模板原仓库。
- **Git 提交**：每次功能/修复完成后在本地 **单独提交一次**，提交信息遵循 [Conventional Commits](https://www.conventionalcommits.org/)。
- **版本号**：
  - 单一来源：`scripts/qwerty-learner-local/oh-app-version.json`（`version` + `versionCode`）。
  - 默认每次发版 **小版本 +0.1**（如 `1.0` → `1.1`），并 **`versionCode` 递增 1**。
  - **大版本**（如 `2.0`）仅在负责人明确要求时修改。
  - 运行 `scripts/bundle-qwerty-learner-local.ps1` 会同步 `AppScope/app.json5`；Web 页脚 `v*` 来自 `OH_APP_VERSION`（同文件）。
