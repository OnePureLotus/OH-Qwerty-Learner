# OH QwertyLearner

<p align="center">
  为键盘工作者设计的单词与肌肉记忆锻炼软件 —— HarmonyOS 离线版
</p>

<p align="center">
  <a href="https://github.com/OnePureLotus/OH-Qwerty-Learner/blob/main/LICENSE"><img src="https://img.shields.io/github/license/OnePureLotus/OH-Qwerty-Learner" alt="License"></a>
  <a href="https://github.com/RealKai42/qwerty-learner"><img src="https://img.shields.io/badge/Upstream-Qwerty%20Learner-blue" alt="Upstream"></a>
</p>

## 简介

**OH QwertyLearner** 将开源 Web 项目 [RealKai42/qwerty-learner](https://github.com/RealKai42/qwerty-learner) 打包进 HarmonyOS 应用，在 **ArkWeb** 中本地运行，无需访问线上 `qwerty.kaiyi.cool` 即可练习打字背单词。

设计目标与上游一致：在敲代码、写文档时顺便巩固英语拼写与肌肉记忆；内置大量词库、音标、默写模式、速度与准确率统计等能力。

本仓库在原生壳层上做了 HarmonyOS 适配（虚拟 HTTPS 域名、`onInterceptRequest` 映射 `rawfile`、HashRouter、自定义词书 JSON 导入等）。应用内「上游仓库」页说明了参考的原版与二开项目及移植范围。

## 功能概览

- **离线词库与练习**：内置上游构建的前端资源（`entry/src/main/resources/rawfile/qwerty-learner/`），含多类考试与编程相关词库。
- **自定义词书**：支持 JSON 导入与词条管理，数据保存在 WebView `localStorage`，无登录、无后端。
- **HarmonyOS 原生壳**：单 Web 容器全屏加载本地站点；2in1 等设备保留模板中的缩放与窗口标题等行为。

## 环境要求

- **HarmonyOS API**：6.1.1 (24) 及以上，对应 DevEco Studio 6.1.x
- **工程路径**：请使用无空格目录 **`OH-Qwerty-Learner`** 打开与编译（见 [`DEVELOPMENT.md`](DEVELOPMENT.md)）
- **更新内置 Web 前端**（可选）：Windows 下在项目根目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\bundle-qwerty-learner-local.ps1
```

脚本会拉取上游 `qwerty-learner`、应用 `scripts/qwerty-learner-local/overlays/` 中的 ArkWeb 补丁，并同步 `oh-app-version.json` 到 `AppScope/app.json5`。

## 构建与安装

1. 用 DevEco Studio 打开本仓库（路径 `OH-Qwerty-Learner`）。
2. 配置签名（修改过 `bundleName` 后需在 DevEco 中重新关联 `signingConfig: default`）。
3. 选择目标设备（手机 / 平板 / 2in1）编译并安装 HAP。

包名：`com.arkwebapp.qwertylearner`  
默认加载：`https://local.qwerty.arkweb/index.html`（由 `QwertyLocalBundleInterceptor` 映射到包内 rawfile）。

## 版本号

- 单一来源：`scripts/qwerty-learner-local/oh-app-version.json`
- 应用内页脚与 `versionName` 保持一致；发版时按 [`DEVELOPMENT.md`](DEVELOPMENT.md) 递增小版本。

## 上游与致谢

| 项目 | 说明 |
|------|------|
| [RealKai42/qwerty-learner](https://github.com/RealKai42/qwerty-learner) | 原版 Web 打字背单词 |
| [likaia/qwerty-learner](https://github.com/likaia/qwerty-learner) | 自定义词书管理等二开参考 |

原生 ArkWeb 壳层思路来自 [ArkWeb 模板](https://github.com/OnePureLotus/ArkWeb-Template-Baidu) 的 Qwerty 本地分支实践，与本产品化仓库分离维护。

## 许可证

本仓库内置的 **Qwerty Learner Web 前端** 遵循上游 **[GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html)**。根目录 [`LICENSE`](LICENSE) 与 [RealKai42/qwerty-learner](https://github.com/RealKai42/qwerty-learner/blob/master/LICENSE) 一致。

在 GPL-3.0 下分发本应用时，请保留许可证与对应源代码获取方式说明；修改上游前端时须以相同许可证提供修改后的源码。

## 反馈与交流

- Issue / PR：[OnePureLotus/OH-Qwerty-Learner](https://github.com/OnePureLotus/OH-Qwerty-Learner)
- 应用内页脚可打开 GitHub 与 QQ 群二维码占位（后续可替换为正式群码）
