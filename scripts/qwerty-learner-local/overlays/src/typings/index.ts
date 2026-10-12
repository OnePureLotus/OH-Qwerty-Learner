export * from './resource'

export type PronunciationType = 'us' | 'uk' | 'romaji' | 'zh' | 'ja' | 'de' | 'hapin' | 'kk' | 'id'
export type PhoneticType = 'us' | 'uk' | 'romaji' | 'zh' | 'ja' | 'de' | 'hapin' | 'kk' | 'id'
export type LanguageType = 'en' | 'romaji' | 'zh' | 'ja' | 'code' | 'de' | 'kk' | 'hapin' | 'id'
export type LanguageCategoryType = 'en' | 'ja' | 'de' | 'code' | 'kk' | 'id' | 'VocabularyBook'

type Pronunciation2PhoneticMap = Record<PronunciationType, PhoneticType>

export const PRONUNCIATION_PHONETIC_MAP: Pronunciation2PhoneticMap = {
  us: 'us',
  uk: 'uk',
  romaji: 'romaji',
  zh: 'zh',
  ja: 'ja',
  de: 'de',
  hapin: 'hapin',
  kk: 'kk',
  id: 'id',
}

export type Word = {
  name: string
  trans: string[]
  usphone: string
  ukphone: string
  notation?: string
}

export type WordWithIndex = Word & {
  index: number
}

export type InfoPanelType = 'donate' | 'vsc' | 'community' | 'redBook'

export type InfoPanelState = {
  [key in InfoPanelType]: boolean
}

export type LoopWordTimesOption = 1 | 3 | 5 | 8 | typeof Number.MAX_SAFE_INTEGER

export type WordDictationType = 'hideAll' | 'hideVowel' | 'hideConsonant' | 'randomHide'
export type WordDictationOpenBy = 'user' | 'auto'
