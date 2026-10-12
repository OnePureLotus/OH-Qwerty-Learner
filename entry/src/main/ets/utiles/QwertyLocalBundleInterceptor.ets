import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { resourceManager } from '@kit.LocalizationKit';

/** Virtual origin for bundled qwerty-learner (avoids resource:// ES module CORS). */
export const QWERTY_LOCAL_ORIGIN: string = 'https://local.qwerty.arkweb/';
export const QWERTY_LOCAL_ENTRY_URL: string = QWERTY_LOCAL_ORIGIN + 'index.html';

const RAW_ROOT: string = 'qwerty-learner/';
const TEXT_DECODER: util.TextDecoder = new util.TextDecoder('utf-8', { ignoreBOM: true });

function mimeTypeFor(relativePath: string): string {
  const lower = relativePath.toLowerCase();
  if (lower.endsWith('.html')) {
    return 'text/html';
  }
  if (lower.endsWith('.js') || lower.endsWith('.mjs')) {
    return 'text/javascript';
  }
  if (lower.endsWith('.css')) {
    return 'text/css';
  }
  if (lower.endsWith('.json') || lower.endsWith('.map')) {
    return 'application/json';
  }
  if (lower.endsWith('.svg')) {
    return 'image/svg+xml';
  }
  if (lower.endsWith('.png')) {
    return 'image/png';
  }
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  if (lower.endsWith('.webp')) {
    return 'image/webp';
  }
  if (lower.endsWith('.ico')) {
    return 'image/x-icon';
  }
  if (lower.endsWith('.woff2')) {
    return 'font/woff2';
  }
  if (lower.endsWith('.woff')) {
    return 'font/woff';
  }
  if (lower.endsWith('.mp3')) {
    return 'audio/mpeg';
  }
  if (lower.endsWith('.wav')) {
    return 'audio/wav';
  }
  return 'application/octet-stream';
}

function isTextLike(mime: string): boolean {
  return mime.startsWith('text/') ||
    mime === 'application/json' ||
    mime === 'image/svg+xml' ||
    mime === 'application/javascript';
}

function toArrayBuffer(data: Uint8Array): ArrayBuffer {
  return data.buffer.slice(data.byteOffset, data.byteOffset + data.byteLength);
}

function mapRequestUrlToRawPath(requestUrl: string): string | null {
  if (!requestUrl.startsWith(QWERTY_LOCAL_ORIGIN)) {
    return null;
  }
  let relative = requestUrl.substring(QWERTY_LOCAL_ORIGIN.length);
  const queryIndex = relative.indexOf('?');
  if (queryIndex >= 0) {
    relative = relative.substring(0, queryIndex);
  }
  const hashIndex = relative.indexOf('#');
  if (hashIndex >= 0) {
    relative = relative.substring(0, hashIndex);
  }
  if (relative.length === 0 || relative === '/') {
    relative = 'index.html';
  }
  if (relative.startsWith('/')) {
    relative = relative.substring(1);
  }
  if (relative.includes('..')) {
    return null;
  }
  return RAW_ROOT + relative;
}

export function interceptQwertyLocalBundleRequest(
  requestUrl: string,
  resourceMgr: resourceManager.ResourceManager
): WebResourceResponse | null {
  const rawPath = mapRequestUrlToRawPath(requestUrl);
  if (!rawPath) {
    return null;
  }
  try {
    const bytes: Uint8Array = resourceMgr.getRawFileContentSync(rawPath);
    const mime = mimeTypeFor(rawPath);
    const response: WebResourceResponse = new WebResourceResponse();
    if (isTextLike(mime)) {
      response.setResponseData(TEXT_DECODER.decodeToString(bytes));
      response.setResponseEncoding('utf-8');
    } else {
      response.setResponseData(toArrayBuffer(bytes));
    }
    response.setResponseMimeType(mime);
    response.setResponseCode(200);
    response.setReasonMessage('OK');
    response.setResponseIsReady(true);
    return response;
  } catch (error) {
    const err = error as BusinessError;
    console.error(`QwertyLocalBundle miss rawPath=${rawPath} url=${requestUrl} code=${err.code} msg=${err.message}`);
    return null;
  }
}
