//这个框架是github框架的上载版本

import { webview } from '@kit.ArkWeb';
import { BusinessError, pasteboard, deviceInfo } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { abilityAccessCtrl, common, ConfigurationConstant, Permissions, Want } from '@kit.AbilityKit';
import { DownloadConfirmDialog } from '../component/DownloadConfirmDialog'
import { IAbstractDownloadHandler } from '../delegate/IWebDownloadFile'
import { WebDownloadFileHelper } from '../delegate/WebDownloadFileImpl'
import { EmitterUtil } from '../utiles/EmitterUtil'
import {
  QWERTY_LOCAL_ENTRY_URL,
  interceptQwertyLocalBundleRequest
} from '../utiles/QwertyLocalBundleInterceptor'
import { http } from '@kit.NetworkKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { call } from '@kit.TelephonyKit';  // 新增：用于拨打电话


//const url = "https://web.feishu.cn"; //飞书
//const url = "https://music.163.com";  //网易云音乐
//const url = "https://www.bilibili.com";  //B站
//const url = "https://chat.deepseek.com";  //deepseek
//const url = "https://www.iconfont.cn";  //阿里巴巴矢量图库
const DEFAULT_URL = QWERTY_LOCAL_ENTRY_URL;
//const url = $rawfile('index (2).html')
//const url = "https://oc.sjtu.edu.cn";
//const url = "https://shuiyuan.sjtu.edu.cn";

// UA设置（修改为更精准的移动端标识）
const forceMobileUA = false;  // 强制手机UA开关设置为true
const mobileUserAgent = "Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36"; // 增强移动端标识
const pcUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"; // 更新PC UA版本
const titleBlankHeight = 0;  //空白标题栏的高度，如果你的网页最上面一排没有按钮和需要点击的内容，可以设置为0
const FIT_TO_WINDOW_MIN_SCALE = 0.5;  // 2in1 自适应缩放下限，避免页面过小难以阅读

// 定义菜单类型枚举
enum MenuType {
  IMAGE = "IMAGE",
  LINK = "LINK",
  EDITABLE = "EDITABLE",
  SELECTION = "SELECTION"
}

class WebChromeBridge {
  private colorHandler: (color: string) => void = () => {
  };

  bindColorHandler(handler: (color: string) => void): void {
    this.colorHandler = handler;
  }

  reportColor(color: string): void {
    if (color && color.length > 0) {
      this.colorHandler(color);
    }
  }
}

@Entry
@Component
struct WebComponent {
  @State permissionsGranted: boolean = false;
  needReloadWhenVisible: boolean = false;
  webIsVisible: boolean = false;
  renderReloadMaxForCrashed: number = 5;
  renderReloadCountForCrashed: number = 0;
  renderReloadMaxForOthers: number = 10;
  renderReloadCountForOthers: number = 0;
  controller: webview.WebviewController = new webview.WebviewController();
  @State webDownloadFile: IAbstractDownloadHandler = new WebDownloadFileHelper()
  downloadWebLoading: CustomDialogController = new CustomDialogController({
    builder: DownloadConfirmDialog(),
    customStyle: true,
    alignment: DialogAlignment.Bottom,
    autoCancel: false,
    isModal: false,
    openAnimation: {
      duration: 200,
      curve: Curve.Ease,
      delay: 0,
      playMode: PlayMode.Normal,
    }
  })
  private result: WebContextMenuResult | undefined = undefined;
  @State linkUrl: string = '';
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State window_width: number = 0;
  @State window_height: number = 0;
  @State menu_height: number = 0;
  @State showMenu: boolean = false;
  @State currentMenuType: MenuType = MenuType.IMAGE;
  @State imageUrl: string = '';
  @State pageChromeColor: string = '#FFFFFFFF';
  private webChromeBridge: WebChromeBridge = new WebChromeBridge();
  private lastAppliedChromeColor: string = '';
  private chromeSyncTimer: number = -1;
  uiContext: UIContext = this.getUIContext();
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  // 从网络URL加载并保存图片到相册
  async saveNetworkImageToGallery(url: string): Promise<boolean> {
    if (!url) {
      console.error('图片URL为空');
      return false;
    }

    try {
      // 1. 通过HTTP请求下载图片
      const httpInstance = http.createHttp();
      const response = await httpInstance.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 60000,
        readTimeout: 60000
      });

      if (response.responseCode !== http.ResponseCode.OK) {
        console.error(`HTTP请求失败，状态码: ${response.responseCode}`);
        return false;
      }

      const imageData: ArrayBuffer = response.result as ArrayBuffer;
      if (!imageData || imageData.byteLength === 0) {
        console.error('获取到的图片数据为空');
        return false;
      }

      // 2. 创建图片源并获取PixelMap
      const imageSource: image.ImageSource = image.createImageSource(imageData);
      const pixelMap: image.PixelMap = await imageSource.createPixelMap();

      // 3. 打包为JPEG格式
      const imagePackerApi = image.createImagePacker();
      const packOpts: image.PackingOption = { format: 'image/jpeg', quality: 98 };
      const buffer: ArrayBuffer = await imagePackerApi.packToData(pixelMap, packOpts);

      // 4. 保存到相册
      const helper = photoAccessHelper.getPhotoAccessHelper(this.context);
      const uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
      const file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await fs.write(file.fd, buffer);
      await fs.close(file.fd);

      // 5. 释放资源
      pixelMap.release();
      httpInstance.destroy();

      return true;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`保存图片失败。Code: ${err.code}, message: ${err.message}`);
      return false;
    }
  }

  // 图片菜单构建器 - 直接包含 SaveButton
  @Builder
  ImageMenuBuilder() {
    Column() {
      // 使用系统安全控件 SaveButton，点击直接保存
      SaveButton()
        .fontSize(14)
        .fontColor('#FFFFFF')           // 深色字体
        .backgroundColor('#000000')     // 浅灰背景
        .width(100)
        .height(45)
        .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
          this.showMenu = false;
          if (result === SaveButtonOnClickResult.SUCCESS) {
            const success = await this.saveNetworkImageToGallery(this.imageUrl);
            if (success) {
              this.uiContext.getPromptAction().showToast({ message: '已保存至相册！' });
            } else {
              this.uiContext.getPromptAction().showToast({ message: '保存失败，请重试' });
            }
          } else {
            this.uiContext.getPromptAction().showToast({ message: '授权失败' });
          }
        })
    }
    .width(100)
    .backgroundColor(Color.Black)
    .borderRadius(8)
    .shadow({
      radius: 10,
      color: '#33000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  // 链接菜单构建器
  @Builder
  LinkMenuBuilder() {
    Menu() {
      MenuItem({ content: '复制链接' })
        .width(100)
        .height(50)
        .onClick(() => {
          let pasteData = pasteboard.createData('text/plain', this.linkUrl);
          pasteboard.getSystemPasteboard().setData(pasteData, (error) => {
            if (error) {
              return;
            }
          })
          this.showMenu = false;
        })
    }
    .width(100)
    .height(50)
  }

  // 可编辑区域菜单构建器
  @Builder
  EditableMenuBuilder() {
    Menu() {
      MenuItem({ content: '剪切' })
        .width(100)
        .height(50)
        .onClick(() => {
          this.result?.cut();
          this.showMenu = false;
        })
      MenuItem({ content: '复制' })
        .width(100)
        .height(50)
        .onClick(() => {
          this.result?.copy();
          this.showMenu = false;
        })
      MenuItem({ content: '粘贴' })
        .width(100)
        .height(50)
        .onClick(() => {
          this.result?.paste();
          this.showMenu = false;
        })
      MenuItem({ content: '全选' })
        .width(100)
        .height(50)
        .onClick(() => {
          this.result?.selectAll();
          this.showMenu = false;
        })
    }
    .width(100)
    .height(200)
  }

  // 选中文本菜单构建器
  @Builder
  SelectionMenuBuilder() {
    Menu() {
      MenuItem({ content: '复制' })
        .width(100)
        .height(50)
        .onClick(() => {
          this.result?.copy();
          this.showMenu = false;
        })
    }
    .width(100)
    .height(50)
  }

  // 动态菜单构建器
  @Builder
  MenuBuilder() {
    if (this.currentMenuType === MenuType.IMAGE) {
      this.ImageMenuBuilder();
    } else if (this.currentMenuType === MenuType.LINK) {
      this.LinkMenuBuilder();
    } else if (this.currentMenuType === MenuType.EDITABLE) {
      this.EditableMenuBuilder();
    } else if (this.currentMenuType === MenuType.SELECTION) {
      this.SelectionMenuBuilder();
    }
  }

  onBackPress() {
    if (this.controller.accessStep(-1)) {
      this.controller.backward();
      return true
    } else {
      return false
    }
  }

  private toSysSettingPage() {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      context.startAbility({
        bundleName: 'com.huawei.hmos.settings',
        abilityName: 'com.huawei.hmos.settings.MainAbility',
        uri: 'application_info_entry',
        parameters: {
          pushParams: context.abilityInfo.bundleName
        }
      }).then(() => {
        console.info('跳转到设置页面成功');
      }).catch((err: BusinessError) => {
        console.error(`跳转到设置页面失败: ${err.code}, ${err.message}`);
        this.uiContext.getPromptAction().showToast({ message: '跳转失败，请手动前往设置' });
      });
    } catch (error) {
      console.error('跳转到设置页面异常:', JSON.stringify(error));
      this.uiContext.getPromptAction().showToast({ message: '跳转失败，请手动前往设置' });
    }
  }

  aboutToAppear(): void {
    EmitterUtil.on<number>('affffa', (event) => {
      if (event?.data === 1) {
        this.downloadWebLoading.open()
      } else {
        this.downloadWebLoading.close()
      }
    })
    this.register2in1WindowSizeListener();
    if (!this.is2in1Device) {
      this.webChromeBridge.bindColorHandler((color: string) => {
        this.onPageChromeColorReported(color);
      });
      this.resetWindowChromeToSystemDefault();
    }
  }

  aboutToDisappear(): void {
    if (this.fitWindowTimer !== -1) {
      clearTimeout(this.fitWindowTimer);
      this.fitWindowTimer = -1;
    }
    EmitterUtil.off<number>('affffa', (event) => {
    })
    webview.WebCookieManager.saveCookieAsync((error) => {
      if (error) {
        console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
      }
    })
  }

  private isProcessingDoubao: boolean = false; // 新增：豆包链接处理状态
  private windowStage = AppStorage.get('window') as window.WindowStage;
  private currentLoadUrl: string = DEFAULT_URL;
  private pageInitialized: boolean = false;
  private readonly is2in1Device: boolean = deviceInfo.deviceType === '2in1';
  // 程序化 zoom 不会触发 onScaleChange，需自行维护当前缩放比例（官方公式基准值）
  private currentPageScale: number = 100;
  private basePageContentWidth: number = 0;
  private webViewWidthPx: number = 0;
  private fitWindowTimer: number = -1;
  private readonly measurePageWidthScript: string =
    '(function(){var d=document.documentElement,b=document.body,w=[d.scrollWidth,d.offsetWidth];' +
    'if(b){w.push(b.scrollWidth,b.offsetWidth);}var m=0;for(var i=0;i<w.length;i++){if(w[i]>m){m=w[i];}}return m;})()';
  private readonly readPageThemeColorScript: string =
    '(function(){function valid(c){return c&&c!==\'transparent\'&&c!==\'rgba(0, 0, 0, 0)\';}' +
    'function cssVar(names){for(var i=0;i<names.length;i++){var v=getComputedStyle(document.documentElement)' +
    '.getPropertyValue(names[i]).trim();if(v&&(v[0]===\'#\'||v.indexOf(\'rgb\')===0)){return v;}}return \'\';}' +
    'function fromEl(el){if(!el){return \'\';}var bg=getComputedStyle(el).backgroundColor;' +
    'if(valid(bg)){return bg;}return el.parentElement?fromEl(el.parentElement):\'\';}' +
    'function readColor(){var m=document.querySelector(\'meta[name="theme-color"]\');' +
    'if(m&&m.content){return m.content;}var x=Math.max(1,Math.floor((window.innerWidth||360)/2));' +
    'var y=Math.max(1,Math.floor((window.innerHeight||640)*0.03));var p=fromEl(document.elementFromPoint(x,y));' +
    'if(p){return p;}var htmlBg=getComputedStyle(document.documentElement).backgroundColor;' +
    'if(valid(htmlBg)){return htmlBg;}var v=cssVar([\'--bg\',\'--background\',\'--surface\',\'--header-bg\']);' +
    'if(v){return v;}var bodyBg=getComputedStyle(document.body).backgroundColor;' +
    'return valid(bodyBg)?bodyBg:\'\';}return readColor();})()';
  private readonly installChromeColorMonitorScript: string =
    '(function(){if(window.__arkWebChromeMonitor){return;}window.__arkWebChromeMonitor=true;' +
    'function valid(c){return c&&c!==\'transparent\'&&c!==\'rgba(0, 0, 0, 0)\';}' +
    'function cssVar(names){for(var i=0;i<names.length;i++){var v=getComputedStyle(document.documentElement)' +
    '.getPropertyValue(names[i]).trim();if(v&&(v[0]===\'#\'||v.indexOf(\'rgb\')===0)){return v;}}return \'\';}' +
    'function fromEl(el){if(!el){return \'\';}var bg=getComputedStyle(el).backgroundColor;' +
    'if(valid(bg)){return bg;}return el.parentElement?fromEl(el.parentElement):\'\';}' +
    'function readColor(){var m=document.querySelector(\'meta[name="theme-color"]\');' +
    'if(m&&m.content){return m.content;}var x=Math.max(1,Math.floor((window.innerWidth||360)/2));' +
    'var y=Math.max(1,Math.floor((window.innerHeight||640)*0.03));var p=fromEl(document.elementFromPoint(x,y));' +
    'if(p){return p;}var htmlBg=getComputedStyle(document.documentElement).backgroundColor;' +
    'if(valid(htmlBg)){return htmlBg;}var v=cssVar([\'--bg\',\'--background\',\'--surface\',\'--header-bg\']);' +
    'if(v){return v;}var bodyBg=getComputedStyle(document.body).backgroundColor;' +
    'return valid(bodyBg)?bodyBg:\'\';}' +
    'function push(){var c=readColor();if(c&&window.arkWebChromeBridge&&window.arkWebChromeBridge.reportColor){' +
    'window.arkWebChromeBridge.reportColor(c);}}' +
    'var obs=new MutationObserver(function(){setTimeout(push,30);});' +
    'function startObs(){if(document.body){obs.observe(document.body,{subtree:true,childList:true,attributes:true,' +
    'attributeFilter:[\'class\',\'style\']});}if(document.documentElement){obs.observe(document.documentElement,' +
    '{attributes:true,attributeFilter:[\'class\',\'style\']});}}' +
    'if(document.readyState===\'loading\'){document.addEventListener(\'DOMContentLoaded\',startObs);}else{startObs();}' +
    'var n=0;var timer=setInterval(function(){push();n++;if(n>=40){clearInterval(timer);}},500);push();})();';

  private updateWebViewWidthPx(widthVp: number): void {
    this.webViewWidthPx = this.uiContext.vp2px(widthVp);
  }

  private parseJsString(result: webview.JsMessageExt | undefined): string {
    if (!result || result.getErrorDescription()) {
      return '';
    }
    if (result.getType() === webview.JsMessageType.STRING) {
      return result.getString().trim();
    }
    return '';
  }

  private cssColorToArgb(color: string): string {
    const trimmed = color.trim();
    if (!trimmed) {
      return '';
    }
    if (trimmed.startsWith('#')) {
      const hex = trimmed.substring(1);
      if (hex.length === 3) {
        const r = hex.charAt(0) + hex.charAt(0);
        const g = hex.charAt(1) + hex.charAt(1);
        const b = hex.charAt(2) + hex.charAt(2);
        return `#FF${r}${g}${b}`.toUpperCase();
      }
      if (hex.length === 6) {
        return `#FF${hex}`.toUpperCase();
      }
      if (hex.length === 8) {
        return `#${hex}`.toUpperCase();
      }
      return '';
    }
    const rgbMatch = trimmed.match(/^rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)(?:\s*,\s*([\d.]+))?\s*\)$/i);
    if (rgbMatch) {
      const r = Math.min(255, Number.parseInt(rgbMatch[1], 10));
      const g = Math.min(255, Number.parseInt(rgbMatch[2], 10));
      const b = Math.min(255, Number.parseInt(rgbMatch[3], 10));
      const a = rgbMatch[4] !== undefined ? Math.round(Number.parseFloat(rgbMatch[4]) * 255) : 255;
      const toHex = (value: number): string => value.toString(16).padStart(2, '0');
      return `#${toHex(a)}${toHex(r)}${toHex(g)}${toHex(b)}`.toUpperCase();
    }
    return '';
  }

  private pickStatusBarContentColor(argb: string): string {
    if (argb.length !== 9) {
      return '#FF000000';
    }
    const r = Number.parseInt(argb.substring(3, 5), 16);
    const g = Number.parseInt(argb.substring(5, 7), 16);
    const b = Number.parseInt(argb.substring(7, 9), 16);
    const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return luminance > 0.6 ? '#FF000000' : '#FFFFFFFF';
  }

  private getDefaultWindowChromeColor(): string {
    const colorMode = this.context.config.colorMode ?? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    const isDark = colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    return isDark ? '#FF1A1A1A' : '#FFFFFFFF';
  }

  private applyWindowChromeColor(argb: string): void {
    if (!argb) {
      return;
    }
    this.pageChromeColor = argb;
    const contentColor = this.pickStatusBarContentColor(argb);
    window.getLastWindow(this.uiContext.getHostContext()).then((win) => {
      try {
        win.setWindowBackgroundColor(argb);
      } catch (error) {
        const err = error as BusinessError;
        console.error(`设置窗口背景色失败: ${err.code}, ${err.message}`);
      }
      win.setWindowSystemBarProperties({
        statusBarContentColor: contentColor,
      }).catch((err: BusinessError) => {
        console.error(`设置状态栏图标颜色失败: ${err.message}`);
      });
    }).catch((err: BusinessError) => {
      console.error(`获取窗口失败: ${err.message}`);
    });
  }

  private resetWindowChromeToSystemDefault(): void {
    this.lastAppliedChromeColor = '';
    this.applyWindowChromeColor(this.getDefaultWindowChromeColor());
  }

  private onPageChromeColorReported(color: string): void {
    const argb = this.cssColorToArgb(color);
    if (!argb || argb === this.lastAppliedChromeColor) {
      return;
    }
    this.lastAppliedChromeColor = argb;
    this.applyWindowChromeColor(argb);
  }

  private syncWindowChromeWithPage(): void {
    if (this.is2in1Device) {
      return;
    }
    try {
      this.controller.runJavaScriptExt(this.readPageThemeColorScript, (error: BusinessError, result) => {
        if (error) {
          return;
        }
        this.onPageChromeColorReported(this.parseJsString(result));
      });
    } catch (error) {
      const err = error as BusinessError;
      console.error(`syncWindowChromeWithPage 异常: ${err.code}, ${err.message}`);
    }
  }

  private installChromeColorMonitor(): void {
    if (this.is2in1Device) {
      return;
    }
    try {
      this.controller.runJavaScript(this.installChromeColorMonitorScript);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`installChromeColorMonitor 异常: ${err.code}, ${err.message}`);
    }
  }

  private scheduleWindowChromeSync(): void {
    if (this.is2in1Device) {
      return;
    }
    if (this.chromeSyncTimer !== -1) {
      clearTimeout(this.chromeSyncTimer);
      this.chromeSyncTimer = -1;
    }
    const delays = [0, 300, 1000, 2500, 5000, 8000];
    delays.forEach((delayMs: number) => {
      setTimeout(() => this.syncWindowChromeWithPage(), delayMs);
    });
    this.installChromeColorMonitor();
  }

  private parseJsNumber(result: webview.JsMessageExt | undefined): number {
    if (!result || result.getErrorDescription()) {
      return 0;
    }
    if (result.getType() === webview.JsMessageType.NUMBER) {
      return result.getNumber();
    }
    if (result.getType() === webview.JsMessageType.STRING) {
      const value = Number.parseFloat(result.getString());
      return Number.isFinite(value) ? value : 0;
    }
    return 0;
  }

  private apply2in1ZoomToRatio(targetRatio: number): void {
    const targetScale = targetRatio * 100;
    if (Math.abs(targetScale - this.currentPageScale) < 1) {
      return;
    }
    const factor = targetScale / this.currentPageScale;
    try {
      this.controller.zoom(factor);
      this.currentPageScale = targetScale;
      console.info(`2in1 缩放: factor=${factor}, scale=${targetScale}, webWidth=${this.webViewWidthPx}, ` +
        `basePage=${this.basePageContentWidth}`);
    } catch (zoomError) {
      const err = zoomError as BusinessError;
      console.error(`网页缩放失败: ${err.code}, ${err.message}`);
    }
  }

  // 2in1：已有基准宽度时，仅按窗口宽度重算缩放（避免 zoom 后 scrollWidth 变小导致误判）
  private fit2in1FromBaseline(): void {
    if (!this.is2in1Device || this.webViewWidthPx <= 0) {
      return;
    }
    if (this.basePageContentWidth <= 0) {
      this.measureAndFit2in1Content();
      return;
    }
    const targetRatio = Math.min(1, Math.max(FIT_TO_WINDOW_MIN_SCALE,
      this.webViewWidthPx / this.basePageContentWidth));
    this.apply2in1ZoomToRatio(targetRatio);
  }

  // 2in1：测量网页在 100% 缩放下的内容宽度，并应用自适应缩放
  private measureAndFit2in1Content(): void {
    if (!this.is2in1Device || this.webViewWidthPx <= 0) {
      return;
    }
    try {
      this.controller.runJavaScriptExt(this.measurePageWidthScript, (error: BusinessError, result) => {
        if (error) {
          console.error(`获取网页宽度失败: ${error.message}`);
          return;
        }
        const pageWidth = this.parseJsNumber(result);
        if (pageWidth <= 0) {
          return;
        }
        if (this.currentPageScale >= 99 || this.basePageContentWidth <= 0 ||
          pageWidth > this.basePageContentWidth * 1.05) {
          this.basePageContentWidth = pageWidth;
        }
        const targetRatio = Math.min(1, Math.max(FIT_TO_WINDOW_MIN_SCALE,
          this.webViewWidthPx / this.basePageContentWidth));
        this.apply2in1ZoomToRatio(targetRatio);
      });
    } catch (error) {
      const err = error as BusinessError;
      console.error(`measureAndFit2in1Content 异常: ${err.code}, ${err.message}`);
    }
  }

  private scheduleFit2in1ContentToWindow(delayMs: number = 200, remeasure: boolean = false): void {
    if (!this.is2in1Device) {
      return;
    }
    if (this.fitWindowTimer !== -1) {
      clearTimeout(this.fitWindowTimer);
    }
    this.fitWindowTimer = setTimeout(() => {
      this.fitWindowTimer = -1;
      if (remeasure) {
        this.measureAndFit2in1Content();
      } else {
        this.fit2in1FromBaseline();
      }
    }, delayMs);
  }

  private schedule2in1FitRetries(): void {
    if (!this.is2in1Device) {
      return;
    }
    const delays = [200, 600, 1200, 2500];
    delays.forEach((delay) => {
      setTimeout(() => {
        this.measureAndFit2in1Content();
      }, delay);
    });
  }

  private register2in1WindowSizeListener(): void {
    if (!this.is2in1Device) {
      return;
    }
    window.getLastWindow(this.uiContext.getHostContext()).then((win) => {
      const properties = win.getWindowProperties();
      if (this.webViewWidthPx <= 0) {
        this.webViewWidthPx = properties.drawableRect.width;
      }
      win.on('windowSizeChange', () => {
        const rect = win.getWindowProperties().drawableRect;
        this.webViewWidthPx = rect.width;
        this.scheduleFit2in1ContentToWindow(100, false);
      });
    }).catch((err: BusinessError) => {
      console.error(`注册窗口尺寸监听失败: ${err.code}, ${err.message}`);
    });
  }

  // 官方建议：src 为空时，在 onControllerAttached 中同步设置 UA 后立即 loadUrl
  private initializeWebPage(): void {
    if (this.pageInitialized) {
      return;
    }
    this.pageInitialized = true;
    try {
      const deviceType = deviceInfo.deviceType;

      if (forceMobileUA) {
        // 强制移动模式：使用自定义移动端 UA
        this.controller.setCustomUserAgent(mobileUserAgent);
      } else if (deviceType === '2in1') {
        // 仅 2in1 使用 PC 版 UA；平板与手机一致，保留系统默认 UA
        this.controller.setCustomUserAgent(pcUserAgent);
      }
      // 手机/平板/可穿戴：不覆盖系统默认 UA（含 OpenHarmony/Mobile），兼容百度等站点

      this.currentLoadUrl = DEFAULT_URL;
      console.info(`加载网页: ${this.currentLoadUrl}`);
      this.controller.loadUrl(this.currentLoadUrl);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`初始化网页失败: ${err.code}, ${err.message}`);
      this.currentLoadUrl = DEFAULT_URL;
      this.controller.loadUrl(this.currentLoadUrl);
    }
  }

  build() {
    Column() {
      Web({ src: '', controller: this.controller })
        .layoutWeight(1)
        .hitTestBehavior(HitTestMode.Transparent)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
          if (newValue.width) {
            this.updateWebViewWidthPx(Number(newValue.width));
            this.fit2in1FromBaseline();
          }
          window.getLastWindow(this.uiContext.getHostContext()).then((data) => {
            const properties = data?.getWindowProperties();
            this.window_width = properties.windowRect.width;
            this.window_height = properties.windowRect.height - titleBlankHeight;
          });
        })
        .onInterceptRequest((event) => {
          if (event?.request) {
            const requestUrl = event.request.getRequestUrl();
            const localResponse: WebResourceResponse | null =
              interceptQwertyLocalBundleRequest(requestUrl, this.context.resourceManager);
            if (localResponse) {
              return localResponse;
            }
          }
          return null;
        })
        // ==================== 新增：处理url scheme跳转外部应用 ====================
        .onLoadIntercept((event) => {
          if (event) {
            let requestUrl: string = event.data.getRequestUrl();
            console.info(`拦截到URL: ${requestUrl}`);

            // 处理 mailto: 链接 - 拉起邮件应用
            if (requestUrl.indexOf('mailto:') === 0) {
              let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
              let want: Want = {
                action: 'ohos.want.action.sendToData',
                uri: requestUrl
              };
              context.startAbility(want).then((data) => {
                console.info(`拉起邮件应用成功: ${JSON.stringify(data)}`);
              }).catch((err: BusinessError) => {
                console.error(`拉起邮件应用失败: ${err.code}, ${err.message}`);
                this.uiContext.getPromptAction().showToast({ message: '拉起邮件应用失败，请检查是否安装邮件应用' });
              });
              return true;  // 拦截该请求，不加载页面
            }

            // 处理 tel:// 链接 - 拉起拨号界面
            if (requestUrl.indexOf('tel://') === 0) {
              let phoneNumber = requestUrl.substring(6);  // 去掉 "tel://" 前缀
              call.makeCall(phoneNumber, (err) => {
                if (!err) {
                  console.info('拉起拨号界面成功');
                } else {
                  console.error(`拉起拨号界面失败: ${JSON.stringify(err)}`);
                  this.uiContext.getPromptAction().showToast({ message: '拉起拨号界面失败' });
                }
              });
              return true;
            }

            // 处理 tel: 链接（有些网页可能使用 tel: 而非 tel://）
            if (requestUrl.indexOf('tel:') === 0 && requestUrl.indexOf('tel://') !== 0) {
              let phoneNumber = requestUrl.substring(4);  // 去掉 "tel:" 前缀
              call.makeCall(phoneNumber, (err) => {
                if (!err) {
                  console.info('拉起拨号界面成功');
                } else {
                  console.error(`拉起拨号界面失败: ${JSON.stringify(err)}`);
                  this.uiContext.getPromptAction().showToast({ message: '拉起拨号界面失败' });
                }
              });
              return true;
            }

            // 处理 sms: 链接 - 拉起短信应用
            if (requestUrl.indexOf('sms:') === 0) {
              let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
              let want: Want = {
                bundleName: 'com.ohos.mms',
                action: 'ohos.want.action.viewData',
                uri: requestUrl
              };
              context.startAbility(want).then((data) => {
                console.info(`拉起短信应用成功: ${JSON.stringify(data)}`);
              }).catch((err: BusinessError) => {
                console.error(`拉起短信应用失败: ${err.code}, ${err.message}`);
                this.uiContext.getPromptAction().showToast({ message: '拉起短信应用失败' });
              });
              return true;
            }

            // 处理 jaccount: 链接 - 拉起交我办APP
            if (requestUrl.indexOf('jaccount:') === 0) {
              let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
              let want: Want = {
                bundleName: 'edu.sjtu.jwb',
                action: 'ohos.want.action.viewData',
                uri: requestUrl
              };
              context.startAbility(want).then((data) => {
                console.info(`拉起交我办APP成功: ${JSON.stringify(data)}`);
              }).catch((err: BusinessError) => {
                console.error(`拉起交我办APP失败: ${err.code}, ${err.message}`);
                this.uiContext.getPromptAction().showToast({ message: '未安装交我办APP，请先安装' });
              });
              return true;
            }

            // 处理 weixin: 链接 - 拉起微信打开
            if (requestUrl.indexOf('weixin://') === 0) {
              let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
              let want: Want = {
                bundleName: 'com.tencent.wechat',
                action: 'ohos.want.action.viewData',
                uri: requestUrl
              };
              context.startAbility(want).then((data) => {
                console.info(`拉起微信成功: ${JSON.stringify(data)}`);
              }).catch((err: BusinessError) => {
                console.error(`拉起微信失败: ${err.code}, ${err.message}`);
                this.uiContext.getPromptAction().showToast({ message: '未安装微信，请先安装' });
              });
              return true;
            }

            // 处理 xhsdiscover: 链接 - 拉起小红书打开
            if (requestUrl.indexOf('xhsdiscover://') === 0) {
              let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
              let want: Want = {
                bundleName: 'com.xingin.xhs_hos',
                action: 'ohos.want.action.viewData',
                uri: requestUrl
              };
              context.startAbility(want).then((data) => {
                console.info(`拉起小红书成功: ${JSON.stringify(data)}`);
              }).catch((err: BusinessError) => {
                console.error(`拉起小红书失败: ${err.code}, ${err.message}`);
                this.uiContext.getPromptAction().showToast({ message: '未安装小红书，请先安装' });
              });
              return true;
            }

            // 处理 QQ登录链接 - 拉起QQ打开
            if (requestUrl.indexOf('https://xui.ptlogin2.qq.com/') === 0) {
              let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
              let want: Want = {
                action: 'ohos.want.action.viewData',
                entities: ['entity.system.browsable'],
                uri: requestUrl
              };
              context.startAbility(want).then((data) => {
                console.info(`拉起QQ成功: ${JSON.stringify(data)}`);
              }).catch((err: BusinessError) => {
                console.error(`拉起QQ失败: ${err.code} - ${err.message}`);
                this.uiContext.getPromptAction().showToast({ message: '未安装QQ，请先安装' });
              });
              return true;
            }

            // 拦截豆包App Linking跳转（添加递归保护）
            if (requestUrl.indexOf('https://www.doubao.com') === 0) {
              // 检查是否已在加载此URL，避免递归
              if (!this.isProcessingDoubao) {
                this.isProcessingDoubao = true;
                console.info(`拦截到豆包链接，在应用内加载: ${requestUrl}`);
                this.controller.loadUrl(requestUrl);
                // 设置超时重置状态，防止永久锁定
                setTimeout(() => {
                  this.isProcessingDoubao = false;
                }, 3000);
                return true;
              } else {
                console.warn('已跳过递归加载豆包链接');
              }
            }
          }
          return false;  // 不拦截其他请求，正常加载
        })
        // ====================处理url scheme跳转外部应用 处理结束 ====================
        .onContextMenuShow((event) => {
          if (event) {
            this.result = event.result;
            this.linkUrl = event.param.getLinkUrl();
            const srcUrl = event.param.getSourceUrl();
            if (srcUrl) {
              this.imageUrl = srcUrl;
            }
            if (event.param.isEditable() == false) {
              if (event.param.getMediaType() === 1) {
                this.currentMenuType = MenuType.IMAGE;
                this.menu_height = 100;
              } else {
                if (event.param.getSelectionText() != "") {
                  this.currentMenuType = MenuType.SELECTION;
                  this.menu_height = 50;
                } else {
                  if (event.param.getUnfilteredLinkUrl() != "") {
                    this.currentMenuType = MenuType.LINK;
                    this.menu_height = 50;
                  } else {
                    return false;
                  }
                }
              }
            } else {
              this.currentMenuType = MenuType.EDITABLE;
              this.menu_height = 200;
            }
          }
          this.offsetX = this.uiContext.px2vp(event.param.x() - this.window_width / 2) + 50;
          this.offsetY = this.uiContext.px2vp(event.param.y() - this.window_height / 2) + this.menu_height / 2;
          this.showMenu = true;
          return true;
        })
        .bindPopup(this.showMenu,
          {
            builder: this.MenuBuilder(),
            enableArrow: false,
            placement: Placement.RightBottom,
            offset: { x: this.offsetX, y: this.offsetY },
            mask: false,
            onStateChange: (e) => {
              if (!e.isVisible) {
                this.showMenu = false;
                this.result!.closeContextMenu();
              }
            }
          })
        .onControllerAttached(() => {
          const permissions: Array<Permissions> = ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE'];
          try {
            abilityAccessCtrl.createAtManager().requestPermissionsFromUser(this.getUIContext().getHostContext() as common.UIAbilityContext, permissions).then((data) => {
              console.info('权限申请结果:', JSON.stringify(data));
            }).catch((err: BusinessError) => {
              console.error('申请权限失败:', JSON.stringify(err));
            });
          } catch (error) {
            console.error('捕获到申请权限异常:', JSON.stringify(error));
          }

          // 先设置 UA 再加载页面，避免先加载后 refresh 导致白屏
          this.initializeWebPage();
          this.webDownloadFile.setAppContext(this.context)
          this.webDownloadFile.setUIContext(this.uiContext)
          this.webDownloadFile.setDownloadDelegate(this.controller)
        })
        .onPageBegin(() => {
          this.lastAppliedChromeColor = '';
          if (this.is2in1Device) {
            this.basePageContentWidth = 0;
            this.currentPageScale = 100;
          }
        })
        .onPageEnd(() => {
          this.controller.setNetworkAvailable(true);
          if (!this.is2in1Device) {
            this.scheduleWindowChromeSync();
          }
          this.schedule2in1FitRetries();
        })
        .onPermissionRequest((event) => {
          if (event) {
            console.info('收到权限请求:', event.request.getOrigin());
            const resources = event.request.getAccessibleResource();
            console.info('请求的资源:', JSON.stringify(resources));

            if (this.permissionsGranted) {
              event.request.grant(resources);
              console.info('自动授予权限');
              return;
            }

            this.uiContext.getPromptAction().showDialog({
              title: '麦克风、相机权限',
              message: '为使用语音输入和音视频通话功能，应用将会访问麦克风、相机。您可以选择拒绝，不会影响其他功能使用。\n\n注意：权限授予需要系统设置和此处双重授权。如果您没有授予系统权限，请前往设置授权后重新启动应用',
              buttons: [
                { text: '拒绝', color: '#666666' },
                { text: '前往设置', color: '#0A59F7' },
                { text: '本次允许', color: '#0A59F7' }
              ]
            }).then((data) => {
              if (data.index === 2) {
                event.request.grant(resources);
                this.permissionsGranted = true;
                console.info('已授予权限');
              } else if (data.index === 1) {
                this.toSysSettingPage();
                console.info('跳转到设置页面');
              } else {
                console.info('用户拒绝授权');
              }
            }).catch((err: Error) => {
              console.error('弹窗异常:', err.message);
            });
          }
        })
        .backgroundColor(Color.Transparent)
        .darkMode(WebDarkMode.Auto)
        .domStorageAccess(true)
        .onlineImageAccess(true)
        .imageAccess(true)
        .fileAccess(true)
        .javaScriptAccess(true)
        .javaScriptProxy({
          object: this.webChromeBridge,
          name: 'arkWebChromeBridge',
          methodList: ['reportColor'],
          controller: this.controller,
        })
        .databaseAccess(true)
        .copyOptions(CopyOptions.LocalDevice)
        .mixedMode(MixedMode.All)
        .zoomAccess(this.is2in1Device)
        .forceEnableZoom(this.is2in1Device)
        .onScaleChange((event) => {
          if (this.is2in1Device) {
            this.currentPageScale = event.newScale;
          }
        })
        .horizontalScrollBarAccess(false)
        .verticalScrollBarAccess(false)
        .onVisibleAreaChange([0, 1.0], (isVisible: boolean) => {
          this.webIsVisible = isVisible;
          if (isVisible && this.needReloadWhenVisible) {
            this.needReloadWhenVisible = false;
            this.controller.loadUrl(this.currentLoadUrl);
          }
        })
        .onRenderExited((event) => {
          if (!event) {
            return;
          }
          if (event.renderExitReason == RenderExitReason.ProcessCrashed) {
            if (this.renderReloadCountForCrashed >= this.renderReloadMaxForCrashed) {
              return;
            }
            console.log('renderReloadCountForCrashed: ' + this.renderReloadCountForCrashed);
            this.renderReloadCountForCrashed++;
          } else {
            if (this.renderReloadCountForOthers >= this.renderReloadMaxForOthers) {
              return;
            }
            console.log('renderReloadCountForOthers: ' + this.renderReloadCountForOthers);
            this.renderReloadCountForOthers++;
          }
          if (this.webIsVisible) {
            this.controller.loadUrl(this.currentLoadUrl);
            return;
          }
          this.needReloadWhenVisible = true;
        })
        .onErrorReceive((event) => {
          if (event) {
            console.error(`onErrorReceive url=${event.request?.getRequestUrl()} err=${JSON.stringify(event.error)}`);
          }
        })
        .onHttpErrorReceive((event) => {
          if (event) {
            console.error(`onHttpErrorReceive url=${event.request.getRequestUrl()} status=${event.response.getResponseCode()}`);
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.pageChromeColor)
  }
}
