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
  <a href="https://github.com/RealKai42/qwerty-learner"><img src="https://img.shields.io/github/stars/RealKai42/qwerty-learner?style=social" alt="Upstream stars" /></a>
</p>

<p align="center">
  <a href="./DEVELOPMENT.md">开发约定</a>
  ·
  <a href="https://github.com/RealKai42/qwerty-learner/blob/master/README.md">上游项目 README</a>
  ·
  <a href="https://github.com/OnePureLotus/OH-Qwerty-Learner/issues">反馈 Issue</a>
</p>

<div align="center">
  <a href="https://trendshift.io/repositories/3239" target="_blank">
    <img src="https://trendshift.io/api/badge/repositories/3239" alt="RealKai42/qwerty-learner on Trendshift" width="250" height="55" />
  </a>
</div>

<div align="center">
  <img src="https://raw.githubusercontent.com/RealKai42/qwerty-learner/master/docs/Screenshot.png" alt="OH QwertyLearner 界面预览（与上游 Web 版一致）" />
</div>

<br />

## 📱 HarmonyOS 版说明

| | |
| --- | --- |
| **应用名称** | OH QwertyLearner |
| **包名** | `com.arkwebapp.qwertylearner` |
| **运行方式** | 内置 `rawfile/qwerty-learner/`，经虚拟域名 `https://local.qwerty.arkweb/` 加载，**无需**访问线上 [qwerty.kaiyi.cool](https://qwerty.kaiyi.cool/) |
| **本仓库** | [OnePureLotus/OH-Qwerty-Learner](https://github.com/OnePureLotus/OH-Qwerty-Learner) |

与浏览器版相比，鸿蒙版额外提供：**系统级安装、全屏 ArkWeb 容器、自定义词书 JSON 导入**（数据存于 WebView `localStorage`，无登录与后端）。应用内页脚「上游仓库」说明了参考的原版与二开项目。

### 构建与安装

1. 使用 **DevEco Studio 6.1.x**，API **6.1.1 (24)+** 打开工程。
2. 工程目录请使用无空格路径：**`OH-Qwerty-Learner`**（见 [`DEVELOPMENT.md`](DEVELOPMENT.md)）。
3. 配置签名后编译 HAP，安装到手机 / 平板 / 2in1。

### 更新内置 Web 前端

在项目根目录执行（会拉取上游、应用 ArkWeb overlays、同步版本号）：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\bundle-qwerty-learner-local.ps1
```

版本号单一来源：`scripts/qwerty-learner-local/oh-app-version.json`（与系统 `versionName`、应用内页脚 `v*` 一致）。

<br />

## 🌐 上游在线版（可选）

若希望在浏览器中使用，请访问上游部署：

**首选**: [https://qwerty.kaiyi.cool/](https://qwerty.kaiyi.cool/) · GitHub Pages: [realkai42.github.io/qwerty-learner](https://realkai42.github.io/qwerty-learner/)

镜像：[GitCode](https://gitcode.com/RealKai42/qwerty-learner/overview) · [Gitee](https://gitee.com/KaiyiWing/qwerty-learner)

上游还提供 [VSCode 插件版](https://marketplace.visualstudio.com/items?itemName=Kaiyi.qwerty-learner)（鸿蒙版为独立封装，不依赖插件）。

<br />

## ✨ 设计思想

软件设计的目标群体为以英语作为主要工作语言的键盘工作者。部分人会出现输入母语时的打字速度快于英语的情况，因为多年的母语输入练就了非常坚固的肌肉记忆 💪，而英语输入的肌肉记忆相对较弱，易出现输入英语时「提笔忘字」的现象。

同时为了巩固英语技能，也需要持续的背诵单词 📕，本软件将英语单词的记忆与英语键盘输入的肌肉记忆的锻炼相结合，可以在背诵单词的同时巩固肌肉记忆。

为了避免造成错误的肌肉记忆，设计上如果用户单词输入错误则需要重新输入单词，尽可能确保用户维持正确的肌肉记忆。

软件也对需要机考英语的人群有一定的帮助。

**For Coder**：

内置了程序员工作常用单词的词库，方便练习工作中常用的单词、提高输入速度。也内置了诸多语言的 API 的练习，帮助程序员快速熟悉常用的 API，更多语言的 API 正在逐步添加中…

<div align="center">
  <img src="https://raw.githubusercontent.com/RealKai42/qwerty-learner/master/docs/coder.png" alt="程序员词库" />
</div>

<br />

## 🛠 功能列表

> 以下能力与上游 Web 版 UI 一致；鸿蒙版在本地包内提供相同体验。

### 词库

内置了常用的 CET-4、CET-6、GMAT、GRE、IELTS、SAT、TOEFL、考研英语、专业四级英语、专业八级英语，也有程序员常见英语单词以及多种编程语言 API 等词库。尽可能满足大部分用户对单词记忆的需求，也非常欢迎社区贡献更多的词库。

<br />

### 音标显示、发音功能

方便用户在记忆单词时，同时记忆读音与音标。

<div align="center">
  <img src="https://raw.githubusercontent.com/RealKai42/qwerty-learner/master/docs/phonetic.jpeg" alt="音标与发音" />
</div>

<br />

### 默写模式

在用户完成一个章节的练习后，会弹出选项是否默写本章，方便用户巩固本章学习的单词。

<div align="center">
  <img src="https://raw.githubusercontent.com/RealKai42/qwerty-learner/master/docs/dictation.png" alt="默写模式" />
</div>

<br />

### 速度、正确率显示

量化用户输入的速度和输入的正确率，让用户有感知的了解自己技能的提升。

<div align="center">
  <img src="https://raw.githubusercontent.com/RealKai42/qwerty-learner/master/docs/speed.jpeg" alt="速度与正确率" />
</div>

<br />

### 鸿蒙版扩展

- **自定义词书**：JSON 导入与词条管理（参考社区二开 [likaia/qwerty-learner](https://github.com/likaia/qwerty-learner) 思路）。
- **离线词库与资源**：词典、音效等均在安装包内，无网亦可练习（发音等仍可能依赖上游在线资源策略，与 Web 版行为一致）。

<br />

## 🏆 荣誉（上游项目）

- Github 全球趋势榜上榜项目
- V2EX 全站热搜项目
- Gitee 全站推荐项目
- [少数派首页推荐](https://sspai.com/post/67535)
- GitCode 开源摘星计划 · [G-Star 计划](https://gitcode.com/g-star)
- Gitee 最有价值开源项目 · [GVP](https://gitee.com/gvp)

<br />

## 📕 词库列表

- CET-4 · CET-6 · GMAT · GRE · IELTS · SAT · TOEFL
- 考研英语 · 专业四级英语 · 专业八级英语
- Coder Dict 程序员常用词 · 高考 · 中考 · 商务英语 · BEC
- 人教版英语 3–9 年级
- 王陆雅思王听力语料库 · 日语 N1–N5 · 哈萨克语基础 3000 词 等

完整列表与贡献方式见 [RealKai42/qwerty-learner](https://github.com/RealKai42/qwerty-learner#-词库列表)。

<br />

## 📗 API 词库

- JavaScript API · Node.js API · Java API · Linux Command · C# List API 等

详见上游 [API 词库说明](https://github.com/RealKai42/qwerty-learner#-api-词库)。

<br />

## 🤝 如何贡献

- **鸿蒙壳层、打包脚本、本仓库 Issue/PR**：[OnePureLotus/OH-Qwerty-Learner](https://github.com/OnePureLotus/OH-Qwerty-Learner)
- **Web 前端与词库**（上游）：[Call for Contributor](https://github.com/RealKai42/qwerty-learner/issues/390) · [贡献准则](https://github.com/RealKai42/qwerty-learner/blob/master/docs/CONTRIBUTING.md) · [导入词典](https://github.com/RealKai42/qwerty-learner/blob/master/docs/toBuildDict.md)

<br />

## 📜 许可证

内置 **Qwerty Learner** Web 前端遵循 **[GNU GPL v3.0](https://www.gnu.org/licenses/gpl-3.0.html)**，根目录 [`LICENSE`](LICENSE) 与 [上游 LICENSE](https://github.com/RealKai42/qwerty-learner/blob/master/LICENSE) 一致。分发与修改时请遵守 GPL-3.0 源码提供义务。

<br />

## 🔗 上游与移植说明

| 仓库 | 角色 |
| --- | --- |
| [RealKai42/qwerty-learner](https://github.com/RealKai42/qwerty-learner) | 原版 Web 打字背单词（本应用 UI 与词库来源） |
| [likaia/qwerty-learner](https://github.com/likaia/qwerty-learner) | 自定义词书管理等二开参考 |
| [ArkWeb-Template-Baidu](https://github.com/OnePureLotus/ArkWeb-Template-Baidu) | 早期 ArkWeb 本地加载实践（与本产品仓库分离维护） |

<br />

## 👨‍💻 Contributors（上游 Web 项目）

<a href="https://github.com/RealKai42/qwerty-learner/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=RealKai42/qwerty-learner" alt="Upstream contributors" />
</a>

<br />

## 🎁 大感谢

以下内容摘自并致谢 [RealKai42/qwerty-learner](https://github.com/RealKai42/qwerty-learner) 原作者与社区。

### 灵感来源

[Keybr](https://www.keybr.com/) · [Typing Academy](https://www.typing.academy) · [react-code-game](https://github.com/webzhd/react-code-game)

### 开源项目

[React](https://github.com/facebook/react) · [Tailwind CSS](https://tailwindcss.com/docs)

### 数据来源

[kajweb/dict](https://github.com/kajweb/dict) · [有道词典](https://www.youdao.com/) · [react-code-game](https://github.com/webzhd/react-code-game)

### 项目 Icon

感谢 [libregd](https://github.com/libregd) 及项目早期支持者（详见[上游 README](https://github.com/RealKai42/qwerty-learner#-大感谢)）。

<br />

## 🌟 Stargazers（上游）

[![Stargazers over time](https://starchart.cc/RealKai42/qwerty-learner.svg)](https://starchart.cc/RealKai42/qwerty-learner)
