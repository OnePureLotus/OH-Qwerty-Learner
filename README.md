<div align="center">
  <img src="https://raw.githubusercontent.com/RealKai42/qwerty-learner/master/src/assets/logo.svg" width="120" alt="OH QwertyLearner Logo" />
</div>

<h1 align="center">OH QwertyLearner</h1>

<p align="center">
  为键盘工作者设计的单词记忆与英语肌肉记忆锻炼软件
</p>

<p align="center">
  <strong>HarmonyOS 离线版</strong> · 封装 <a href="https://github.com/RealKai42/qwerty-learner">Qwerty Learner</a> 同款 Web UI，在 ArkWeb 中本地运行
</p>

<p align="center">
  <a href="https://github.com/OnePureLotus/OH-Qwerty-Learner/blob/main/LICENSE"><img src="https://img.shields.io/github/license/OnePureLotus/OH-Qwerty-Learner?label=License" alt="License" /></a>
  <a href="https://github.com/OnePureLotus/OH-Qwerty-Learner"><img src="https://img.shields.io/badge/Platform-HarmonyOS-blue" alt="HarmonyOS" /></a>
  <a href="https://github.com/OnePureLotus/OH-Qwerty-Learner"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs welcome" /></a>
  <a href="https://github.com/RealKai42/qwerty-learner"><img src="https://img.shields.io/badge/Powered%20by-React-61dafb" alt="React" /></a>
</p>

<p align="center">
  <a href="./DEVELOPMENT.md">开发约定</a>
  ·
  <a href="https://github.com/RealKai42/qwerty-learner/blob/master/README.md">上游项目 README</a>
  ·
  <a href="https://github.com/OnePureLotus/OH-Qwerty-Learner/issues">反馈 Issue</a>
</p>

<div align="center">
  <img src="https://raw.githubusercontent.com/RealKai42/qwerty-learner/master/docs/Screenshot.png" alt="OH QwertyLearner 界面预览（与上游 Web 版一致）" />
</div>

<br />

## 📱 HarmonyOS 版说明

| **应用名称** | OH QwertyLearner |
| --- | --- |
| **包名** | `com.arkwebapp.qwertylearner` |
| **运行方式** | 内置 `rawfile/qwerty-learner/`，经虚拟域名 `https://local.qwerty.arkweb/` 加载 |
| **本仓库** | [OnePureLotus/OH-Qwerty-Learner](https://github.com/OnePureLotus/OH-Qwerty-Learner) |

与浏览器版相比，鸿蒙版额外提供：**系统级安装、全屏 ArkWeb 容器、自定义词书 JSON 导入**（数据存于 WebView `localStorage`）。应用内页脚「上游仓库」说明了参考的原版与二开项目。

### 构建与安装

1. 使用 **DevEco Studio 6.1.x**，API **6.1.1 (24)+** 打开工程。
3. 配置签名后编译 HAP，安装到手机 / 平板 / 2in1。

### 鸿蒙版扩展

- **自定义词书**：JSON 导入与词条管理。
- **离线词库与资源**：词典、音效等均在安装包内，无网亦可练习。

## 🤝 如何贡献

- **鸿蒙壳层、打包脚本、本仓库 Issue/PR**：[OnePureLotus/OH-Qwerty-Learner](https://github.com/OnePureLotus/OH-Qwerty-Learner)
- **Web 前端与词库**（上游）：[Call for Contributor](https://github.com/RealKai42/qwerty-learner/issues/390) · [贡献准则](https://github.com/RealKai42/qwerty-learner/blob/master/docs/CONTRIBUTING.md) · [导入词典](https://github.com/RealKai42/qwerty-learner/blob/master/docs/toBuildDict.md)

## 📜 许可证

内置 **Qwerty Learner** Web 前端遵循 **[GNU GPL v3.0](https://www.gnu.org/licenses/gpl-3.0.html)**，根目录 [`LICENSE`](LICENSE) 与 [上游 LICENSE](https://github.com/RealKai42/qwerty-learner/blob/master/LICENSE) 一致。分发与修改时请遵守 GPL-3.0 源码提供义务。

## 🔗 上游与移植说明

| 仓库 | 角色 |
| --- | --- |
| [RealKai42/qwerty-learner](https://github.com/RealKai42/qwerty-learner) | 原版 Web 打字背单词 |
| [likaia/qwerty-learner](https://github.com/likaia/qwerty-learner) | 自定义词书管理等二开参考 |

