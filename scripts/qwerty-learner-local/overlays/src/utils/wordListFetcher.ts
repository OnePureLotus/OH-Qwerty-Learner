import type { Word } from '@/typings'

export async function wordListFetcher(url: string): Promise<Word[]> {
  const URL_PREFIX: string = REACT_APP_DEPLOY_ENV === 'pages' ? '/qwerty-learner' : ''
  const isArkWeb = REACT_APP_ARKWEB === 'true'
  const requestUrl = isArkWeb && url.startsWith('/') ? `.${url}` : URL_PREFIX + url
  const response = await fetch(requestUrl)
  const words: Word[] = await response.json()
  return words
}
