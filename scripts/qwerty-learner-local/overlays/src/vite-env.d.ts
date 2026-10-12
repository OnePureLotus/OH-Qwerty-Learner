/// <reference types="vite/client" />
declare const REACT_APP_DEPLOY_ENV: string
declare const REACT_APP_ARKWEB: string
declare const OH_APP_VERSION: string
declare const LATEST_COMMIT_HASH: string

declare module '*.jpg' {
  const src: string
  export default src
}
