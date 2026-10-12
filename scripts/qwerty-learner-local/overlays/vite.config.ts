import react from '@vitejs/plugin-react'
import { readFileSync } from 'node:fs'
import { promises as fs } from 'fs'
import jotaiDebugLabel from 'jotai/babel/plugin-debug-label'
import jotaiReactRefresh from 'jotai/babel/plugin-react-refresh'
import path from 'node:path'
import { visualizer } from 'rollup-plugin-visualizer'
import Icons from 'unplugin-icons/vite'
import { defineConfig } from 'vite'
import type { PluginOption } from 'vite'

function readAppVersion(): string {
  const versionFile = path.resolve(__dirname, '..', 'oh-app-version.json')
  try {
    const raw = readFileSync(versionFile, 'utf-8')
    const parsed = JSON.parse(raw) as { version?: string }
    return parsed.version ?? '1.0'
  } catch {
    return '1.0'
  }
}

// https://vitejs.dev/config/
export default defineConfig(async ({ mode }) => {
  const appVersion = readAppVersion()
  return {
    plugins: [
      react({ babel: { plugins: [jotaiDebugLabel, jotaiReactRefresh] } }),
      visualizer() as PluginOption,
      Icons({
        compiler: 'jsx',
        jsx: 'react',
        customCollections: {
          'my-icons': {
            xiaohongshu: () => fs.readFile('./src/assets/xiaohongshu.svg', 'utf-8'),
          },
        },
      }),
    ],
    build: {
      minify: true,
      outDir: 'build',
      sourcemap: false,
    },
    esbuild: {
      drop: mode === 'development' ? [] : ['console', 'debugger'],
    },
    define: {
      REACT_APP_DEPLOY_ENV: JSON.stringify(process.env.REACT_APP_DEPLOY_ENV),
      REACT_APP_ARKWEB: JSON.stringify(process.env.REACT_APP_ARKWEB ?? ''),
      OH_APP_VERSION: JSON.stringify(appVersion),
      LATEST_COMMIT_HASH: JSON.stringify(''),
    },
    resolve: {
      alias: {
        '@': path.resolve(__dirname, 'src'),
      },
    },
    css: {
      modules: {
        localsConvention: 'camelCaseOnly',
      },
    },
  }
})
