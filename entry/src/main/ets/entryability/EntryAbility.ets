import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { webview } from '@kit.ArkWeb';
import { image } from '@kit.ImageKit';

const DOMAIN = 0x0000;
const APP_TITLE = 'OH QwertyLearner';

export default class EntryAbility extends UIAbility {
  private configure2in1Window(windowClass: window.Window): void {
    try {
      // 自由窗口下显示系统标题栏：左上角图标+名称，右上角最大化/最小化/关闭
      windowClass.setWindowDecorVisible(true);
      windowClass.setWindowDecorHeight(40);
      windowClass.setWindowTitleButtonVisible(true, true, true);
      windowClass.setWindowTitle(APP_TITLE).then(() => {
        hilog.info(DOMAIN, 'testTag', 'Succeeded in setting window title.');
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, 'testTag', 'Failed to set window title: %{public}s', JSON.stringify(err));
      });
      this.set2in1WindowIcon();
    } catch (exception) {
      const err = exception as BusinessError;
      hilog.error(DOMAIN, 'testTag', 'Failed to configure 2in1 window decor: %{public}s', JSON.stringify(err));
    }
  }

  private getDefaultWindowChromeColor(): string {
    const isDark = this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    return isDark ? '#FF1A1A1A' : '#FFFFFFFF';
  }

  private getDefaultStatusBarContentColor(): string {
    const isDark = this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    return isDark ? '#FFFFFFFF' : '#FF000000';
  }

  private configureWindowChrome(windowClass: window.Window): void {
    try {
      // 组件安全区方案：状态栏默认透明，透出窗口背景色（见官方「开发应用沉浸式效果」）
      windowClass.setWindowBackgroundColor(this.getDefaultWindowChromeColor());
      windowClass.setWindowSystemBarProperties({
        statusBarContentColor: this.getDefaultStatusBarContentColor(),
      }).then(() => {
        hilog.info(DOMAIN, 'testTag', 'Succeeded in setting window chrome properties.');
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, 'testTag', 'Failed to set window chrome properties: %{public}s', JSON.stringify(err));
      });
    } catch (exception) {
      const err = exception as BusinessError;
      hilog.error(DOMAIN, 'testTag', 'Failed to configure window chrome: %{public}s', JSON.stringify(err));
    }
  }

  private set2in1WindowIcon(): void {
    try {
      this.context.resourceManager.getMediaContent($r('app.media.foreground').id).then((data) => {
        const imageSource = image.createImageSource(data.buffer);
        imageSource.createPixelMap().then((pixelMap) => {
          this.context.setMissionWindowIcon(pixelMap).then(() => {
            hilog.info(DOMAIN, 'testTag', 'Succeeded in setting mission window icon.');
          }).catch((err: BusinessError) => {
            hilog.error(DOMAIN, 'testTag', 'setMissionWindowIcon failed: %{public}s', JSON.stringify(err));
          });
        }).catch((err: BusinessError) => {
          hilog.error(DOMAIN, 'testTag', 'createPixelMap failed: %{public}s', JSON.stringify(err));
        });
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, 'testTag', 'getMediaContent failed: %{public}s', JSON.stringify(err));
      });
    } catch (exception) {
      const err = exception as BusinessError;
      hilog.error(DOMAIN, 'testTag', 'Failed to set 2in1 window icon: %{public}s', JSON.stringify(err));
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    //开启BFCache，显著提升用户返回至先前浏览网页的速度
    let features = new webview.BackForwardCacheSupportedFeatures();
    features.nativeEmbed = true;
    features.mediaTakeOver = true;
    webview.WebviewController.enableBackForwardCache(features);
    webview.WebviewController.initializeWebEngine();
    AppStorage.setOrCreate("abilityWant", want);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    let applicationContext = this.context.getApplicationContext();
    //强制应用为深色模式
    //applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    //强制应用为浅色模式
    //applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);

    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err:BusinessError) => {
      let windowClass = windowStage.getMainWindowSync();
      let deviceTypeInfo: string = deviceInfo.deviceType;
      //窗体启动时强制全屏功能，且不显示标题栏和dock栏
      //windowClass?.maximize(window.MaximizePresentation.ENTER_IMMERSIVE); //进入全屏模式
      //windowClass?.setTitleAndDockHoverShown(false, false); //是否显示标题栏和dock栏

      if (deviceTypeInfo === '2in1') {
        this.configure2in1Window(windowClass);
      } else {
        this.configureWindowChrome(windowClass);
      }
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    }
    )
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}