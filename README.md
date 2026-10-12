> **App branch**: `app/qwerty-learner-local`
> - **Display name**: OH QwertyLearner
> - **Bundle name**: `com.arkwebapp.qwertylearner`
> - **Default URL**: `https://local.qwerty.arkweb/index.html`（虚拟 HTTPS + `onInterceptRequest` 映射到 `rawfile/qwerty-learner/`，避免 ES module 跨域白屏）
> - **Description**: HarmonyOS ArkWeb app with bundled Qwerty Learner web UI and dictionaries (not the hosted qwerty.kaiyi.cool site). Supports **local custom wordbooks** (JSON import + word management, no login/backend).

---

# ArkWeb 框架 · 正式模板 v1.2

基于 ArkWeb 的 H5 嵌入式鸿蒙应用模板。即使零基础，也可通过修改配置与网页地址，快速构建自己的鸿蒙应用。

**当前分支示例**：应用名「OH QwertyLearner」，包名 `com.arkwebapp.qwertylearner`，加载本地 `rawfile/qwerty-learner/`（由 `scripts/bundle-qwerty-learner-local.ps1` 从上游仓库构建同步）。**请在本机使用无空格目录** `OH-Qwerty-Learner` **进行编译与提交**（见 `DEVELOPMENT.md`）。

**与 `app/qwerty-learner` 的区别**：`app/qwerty-learner` 加载线上 `https://qwerty.kaiyi.cool/`；本分支内置上游 Vite 构建产物（词库、`dicts/`、音效等均在包内），无需依赖该站点即可练习。

**更新内置前端**：在项目根目录执行 `powershell -ExecutionPolicy Bypass -File scripts\bundle-qwerty-learner-local.ps1`，会拉取 [RealKai42/qwerty-learner](https://github.com/RealKai42/qwerty-learner)、应用 `scripts/qwerty-learner-local/overlays/`（HashRouter、词库路径等 ArkWeb 适配）并覆盖 `rawfile/qwerty-learner/`。

**构建要求**：HarmonyOS API **6.1.1(24)**，DevEco Studio 对应 6.1.x 版本。

---

## 目录

- [功能概览](#功能概览)
- [快速部署](#快速部署)
- [核心配置说明](#核心配置说明)
- [PC/2in1 适配](#pc2in1-适配)
- [修改包名与签名](#修改包名与签名)
- [网页安全区适配](#网页安全区适配)
- [深色模式状态栏（临时方案）](#深色模式状态栏临时方案)
- [URL Scheme 跳转](#url-scheme-跳转)
- [User-Agent 策略](#user-agent-策略)
- [拦截 App Linking 强制跳转](#拦截-app-linking-强制跳转)
- [能力边界与约束](#能力边界与约束)
- [致谢](#致谢)

---

## 功能概览

| 类别 | 能力 |
| --- | --- |
| 网页加载 | 远程 URL / 本地 `rawfile` HTML 自由嵌入 |
| 状态栏 | 随网页 `theme-color` / 顶栏背景色自适应（内容不延伸至状态栏） |
| 沉浸式 | 底部安全区（导航条）沉浸式适配 |
| 系统控件 | 安全访问文件、相机、保存到相册 |
| 右键菜单 | 图片保存、复制链接、选中文本等扩展菜单 |
| 下载 | 下载监听与确认框，支持安全保存文件 |
| URL Scheme | 内置 `mailto`、`tel`、`sms`、`weixin`、`xhsdiscover`、`jaccount` 等跳转示例 |
| 权限 | 相机、麦克风二次确认；可跳转系统权限设置页 |
| 系统状态 | 网络状态、深/浅色模式反馈给网页 |
| UA | 按设备类型自动选择 UA（见下文） |
| App Linking | 可拦截强制拉端，在应用内继续浏览（豆包示例） |
| 2in1 | 自由窗口标题栏 + 网页自适应缩放 |

**内置权限**（`module.json5`）：`INTERNET`、`GET_NETWORK_INFO`、`CAMERA`、`MICROPHONE`、`PRINT`。

---

## 快速部署

1. 使用 **DevEco Studio** 打开本项目文件夹（整体导入）。
2. 修改网页地址：见 [核心配置说明](#核心配置说明)。
3. 修改应用名称、图标、包名：见下方文件列表。
4. **Signing Configs** 勾选自动签名，生成调试证书。
5. 选择目标设备，点击运行。

**零基础用法**：用 AI 生成 HTML，放入 `entry/src/main/resources/rawfile/`，将 `DEFAULT_URL` 改为 `$rawfile('your.html')` 即可。

### 需要修改的文件

| 文件 | 修改内容 |
| --- | --- |
| `entry/src/main/ets/pages/Index.ets` | `DEFAULT_URL`、UA 常量、`FIT_TO_WINDOW_MIN_SCALE` |
| `AppScope/app.json5` | `bundleName`、版本号 |
| `AppScope/resources/base/element/string.json` | `app_name`（桌面显示名） |
| `entry/src/main/resources/base/element/string.json` | `EntryAbility_label`、权限说明文案 |
| `entry/src/main/module.json5` | 权限声明（`startWindowIcon` 引用 `start_icon`） |
| `entry/src/main/ets/entryability/EntryAbility.ets` | 2in1 窗口标题 `APP_TITLE` |
| `entry/.../media/<app>.svg` | Logo **矢量源文件**（设计稿，保留在仓库） |
| `entry/.../media/foreground.png` | 模块级桌面图标前景（**从 SVG 导出的 PNG**，512×512，Logo 满画布） |
| `entry/.../media/background.png` | 模块级图标背景（**全透明**，禁止品牌色底） |
| `entry/.../media/start_icon.png` | **启动页图标**（从 SVG 导出的 PNG，256×256，Logo 满画布，参考 `main` 百度模板） |
| `AppScope/.../media/app_foreground.png` | 应用级桌面图标前景（**PNG**） |
| `AppScope/.../media/app_background.png` | 应用级图标背景（**全透明**） |
| `build-profile.json5` | 改包名后确认 `products.default.signingConfig` 为 `"default"` |

> `bundleName`（包名）与 `app_name`（显示名）相互独立。修改包名后必须重新签名，见 [修改包名与签名](#修改包名与签名)。

### 图标规范（`app/*` 分支必遵）

已验证参考分支：`app/github`。

| 用途 | 文件 | 画布 | Logo 占比 | 格式 |
| --- | --- | --- | --- | --- |
| 设计稿 | `<app-name>.svg` | — | — | SVG 矢量源，保留在仓库 |
| 桌面图标前景 | `foreground.png` / `app_foreground.png` | 512×512 | **满画布 100%** | PNG（从 SVG 导出） |
| 桌面图标背景 | `background.png` / `app_background.png` | 512×512 | 全透明 | PNG |
| 启动加载页 | `start_icon.png` | 256×256 | **满画布 100%** | PNG（从 SVG 导出） |

**导出步骤**：获取官方 SVG → 裁切透明边距 → 缩放至**填满目标画布** → 导出上述 PNG。尺寸标准与 `main` 分支百度模板一致。

**禁止事项**：

- 禁止将 SVG 直接用于 `layered-image` 或 `startWindowIcon`（桌面会显示拼图占位符）
- 禁止在 `background` 层填充品牌背景色
- 禁止 Logo 仅占画布 30%～60%（桌面和启动页都会显得过小）
- 禁止遗漏 `start_icon.png`（启动页仍显示模板默认图标）

### 应用分支定制检查清单

创建 `app/*` 分支时，除上表文件外请逐项确认：

- [ ] 已保存 SVG 源文件（如 `github.svg`）并导出全部运行时 PNG
- [ ] `foreground.png` / `app_foreground.png`：512×512，Logo **满画布**
- [ ] `background.png` / `app_background.png`：**全透明**
- [ ] `start_icon.png`：256×256，Logo **满画布**
- [ ] 改 `bundleName` 后已在 DevEco 重新生成签名，且 `build-profile.json5` 中 `products` 关联了 `signingConfig: "default"`（否则产出 `unsigned.hap`，安装报 `9568320`）
- [ ] 未将本机签名证书路径提交到 Git

完整 AI / 开发者约束见 [`TEMPLATE_PROMPT.md`](TEMPLATE_PROMPT.md)。

---

## 核心配置说明

### 网页地址

在 `Index.ets` 顶部修改：

```typescript
const DEFAULT_URL = "https://www.baidu.com";
// 本地页面示例：
// const DEFAULT_URL = $rawfile('index.html');
```

文件顶部注释中保留了飞书、B 站、网易云等常用地址，取消注释即可切换。

### 网页加载机制

- `Web({ src: '' })` 初始为空，在 `onControllerAttached` 中**先设置 UA，再 `loadUrl`**，避免白屏。
- 不在加载后调用 `refresh()` 换 UA。

### 2in1 缩放下限

```typescript
const FIT_TO_WINDOW_MIN_SCALE = 0.5;  // 自适应最小缩放比例（50%）
```

---

## PC/2in1 适配

### 自由窗口标题栏

在 **2in1 设备**（不含平板）以自由窗口运行时，显示系统标题栏：

- **左上角**：应用图标 + 名称（`setWindowTitle` / `setMissionWindowIcon`）
- **右上角**：最大化、最小化、关闭

配置位于 `EntryAbility.ets` 的 `configure2in1Window()`。隐藏标题栏可调用 `setWindowDecorVisible(false)`，详见[应用适配自由窗口](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-adaptation-freeform-window)。

### 网页自适应缩放

2in1 使用 **PC 版 UA** 加载网页。页面加载完成及窗口尺寸变化时，框架会：

1. 用 JavaScript 测量页面在 100% 缩放下的内容宽度，缓存为基准宽度；
2. 按 `窗口宽度 ÷ 基准宽度` 计算目标缩放比；
3. 调用 `zoom` 等比缩小（不低于 `FIT_TO_WINDOW_MIN_SCALE`）；
4. 程序化缩放后**手动维护**缩放比例（`onScaleChange` 仅在手势缩放时触发）。

相关逻辑均在 `Index.ets` 中，已启用 `zoomAccess` 与 `forceEnableZoom`，用户仍可用 Ctrl+滚轮手动缩放。

**平板与手机不做此处理**，行为与系统浏览器一致。

---

## 修改包名与签名

修改 `AppScope/app.json5` 中的 `bundleName` 后，若未同步更新签名，构建会在 `SignHap` 阶段失败：

```
The bundleName in app.json5/hvigorfile.ts does not match the bundleName in the generated SigningConfigs.
```

或在设备上安装时报错：

```
Install Failed: code:9568320 / error: no signature file
```

此时构建产物为 `entry-default-unsigned.hap`（未签名），通常是因为 **产品未关联签名配置**。

**处理步骤（在 DevEco Studio 中手动操作）：**

1. 修改 `bundleName` 为你的包名（如 `com.arkwebapp.myapp`）
2. 打开 **File → Project Structure → Project → Signing Configs**
3. 勾选 **Automatically generate signature**
4. 点击 **Fix** 或 **Apply**
5. 确认 `build-profile.json5` 中 `products` → `default` 包含 `"signingConfig": "default"`（模板已预设；若 DevEco 覆盖后缺失需手动补回）
6. 重新编译运行，确认输出为已签名 HAP（非 `*-unsigned.hap`）

---

## 状态栏与底部安全区

**手机/平板**：网页内容**不**延伸至状态栏下方，保持在系统安全区内。页面加载完成后，`Index.ets` 的 `syncStatusBarWithPage()` 会读取网页 `meta[name=theme-color]` 或顶栏/页面背景色，同步系统状态栏背景与图标颜色。启动时 `EntryAbility.configureSystemBarWindow()` 按系统深/浅色模式设置初始状态栏颜色，避免首屏闪烁。

各 `app/*` 分支若站点未提供 `theme-color`，可在 `EntryAbility.ets` 的 `configureSystemBarWindow()` 中写入固定色值（如 Flashcards 使用 `#FF232323`）。

**底部导航条**：Web 组件使用 `expandSafeArea` 扩展至 BOTTOM。若网页底部控件被遮挡，可用 `env(safe-area-inset-bottom)` 避让：

```css
.tabs {
  justify-content: space-around;
  bottom: 0;
  height: calc(env(safe-area-inset-bottom) + 40px);
}
```

**2in1 设备**不调整状态栏，仍使用自由窗口标题栏。

详见官方文档：[网页安全区域](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/web-safe-area-insets)。

---

## URL Scheme 跳转

本方案无需注册 App Linking 或修改 `module.json5` 的关联名单，只需知道 **scheme 前缀** 与 **目标应用包名**。

源码 `Index.ets` 的 `onLoadIntercept` 中已包含：`mailto`、`tel`、`sms`、`weixin`、`xhsdiscover`、`jaccount` 等示例。搜索对应前缀即可定位并仿照添加。

### 添加自定义 Scheme（以交我办为例）

前缀为 `jaccount:`，包名为 `edu.sjtu.jwb`：

```typescript
if (requestUrl.indexOf('jaccount:') === 0) {
  let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  let want: Want = {
    bundleName: 'edu.sjtu.jwb',
    action: 'ohos.want.action.viewData',
    uri: requestUrl
  };
  context.startAbility(want).then((data) => {
    console.info(`拉起应用成功: ${JSON.stringify(data)}`);
  }).catch((err: BusinessError) => {
    console.error(`拉起应用失败: ${err.code}, ${err.message}`);
    this.uiContext.getPromptAction().showToast({ message: '未安装目标应用' });
  });
  return true;
}
```

### 通过浏览器拉起（QQ 登录等）

部分链接指定包名会提示「暂无可用打开方式」，可不指定 `bundleName`，改用：

```typescript
entities: ['entity.system.browsable']
```

源码中 QQ 登录链接已按此方式处理。

参考：[H5 通过 URL Scheme 拉起应用](https://developer.huawei.com/consumer/cn/doc/architecture-guides/app_pull_up-0000002353615821)

---

## User-Agent 策略

当前模板逻辑（`initializeWebPage()`）：

| 设备 | UA |
| --- | --- |
| `forceMobileUA = true` | 强制使用 `mobileUserAgent` |
| 2in1 | 使用 `pcUserAgent`（桌面版网页 + 自适应缩放） |
| 手机 / 平板 / 可穿戴 | **保留系统默认 UA**（含 OpenHarmony/Mobile 标识） |

相关常量位于 `Index.ets` 顶部：

```typescript
const forceMobileUA = false;
const mobileUserAgent = "Mozilla/5.0 (Linux; Android 13; Mobile) ...";
const pcUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ...";
```

**常见调整：**

- 2in1 也想看移动版页面：将 `forceMobileUA` 设为 `true`，或把 `DEFAULT_URL` 改为 `https://m.baidu.com`
- 需要鸿蒙应用商店等特有 UA：在 `mobileUserAgent` / `pcUserAgent` 末尾追加自定义标识

> PC/2in1 上 UA 不含 `Mobile` 时，网页 `<meta viewport>` 默认关闭；2in1 上 `metaViewport` 属性**无效果**，详见 [能力边界](#能力边界与约束)。

---

## 拦截 App Linking 强制跳转

ArkWeb 默认会在已安装目标应用时自动拉端。若希望在应用内继续浏览，在 `onLoadIntercept` 中拦截对应 URL 并 `loadUrl` 加载（注意 URL 末尾可能被自动追加 `/`）。

豆包示例（含递归保护）：

```typescript
private isProcessingDoubao: boolean = false;

if (requestUrl.indexOf('https://www.doubao.com') === 0) {
  if (!this.isProcessingDoubao) {
    this.isProcessingDoubao = true;
    this.controller.loadUrl(requestUrl);
    setTimeout(() => { this.isProcessingDoubao = false; }, 3000);
    return true;
  }
}
```

---

## 能力边界与约束

使用本模板前，请了解以下**无法通过框架绕过**的限制：

### 第三方网页显示（2in1）

| 限制 | 说明 |
| --- | --- |
| 网页固定最小宽度 | 桌面站常见 `min-width: 1000px+`。框架只能整页 zoom，不能让布局变窄到完全贴合窗口。 |
| 缩放下限 | 默认最多缩小到 50%。窗口小于「页面最小宽度 × 50%」时，仍可能裁切。 |
| viewport 无效 | PC/2in1 上 `<meta viewport>` 不生效，`metaViewport`、`overviewModeAccess` 无效。 |
| 动态内容 | 广告、弹窗等异步加载会改变宽度；框架在加载后多次重试测量，但无法覆盖所有情况。 |

**改善建议：**

1. 使用响应式站点或移动版 URL（如 `m.baidu.com`）
2. 自建 `rawfile` HTML，使用弹性布局，避免固定 `min-width`
3. 设置 `forceMobileUA = true` 获取移动版页面
4. 用户手动 Ctrl+滚轮进一步缩放

### 签名与包名

- 包名与调试证书绑定，**改包名必须重新签名**（不会自动修复）
- `build-profile.json5` 中的签名路径为本机生成，勿提交到公开仓库

### 白屏规避

- 不要在设置 UA 后对同一页面调用 `refresh()`
- 不要用 `about:blank` 占位再异步 `loadUrl`
- 使用 `src: ''` + `onControllerAttached` 同步加载

### API 迁移说明（v1.2 相对早期版本）

- `targetSdkVersion` / `compatibleSdkVersion`：`6.1.1(24)`
- `promptAction` → `uiContext.getPromptAction()`
- 上下文通过 `setAppContext` / `setUIContext` 注入，避免在静态方法中直接 `getContext()`

---

## 致谢

本项目参考了以下开源项目的设计思路：

- [littlestone/WebApp-ohos](https://github.com/littlestone0806/WebApp-ohos)
