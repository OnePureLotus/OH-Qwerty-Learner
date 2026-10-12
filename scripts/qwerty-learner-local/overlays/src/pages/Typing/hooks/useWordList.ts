import { CHAPTER_LENGTH } from '@/constants'
import { currentChapterAtom, currentDictInfoAtom, refreshCustomWordBookAtom, reviewModeInfoAtom } from '@/store'
import type { Word, WordWithIndex } from '@/typings/index'
import type { CustomWordRow } from '@/utils/customWordBook/types'
import { wordListFetcher } from '@/utils/wordListFetcher'
import { useAtom, useAtomValue } from 'jotai'
import { useEffect, useMemo } from 'react'
import useSWR from 'swr'

/** Stable empty list so useMemo(words) does not invalidate every render. */
const EMPTY_WORDS: Word[] = []

export type UseWordListResult = {
  words: WordWithIndex[]
  isLoading: boolean
  error: Error | undefined
}

function customRowsToWords(rows: CustomWordRow[]): Word[] {
  return rows.map((row) => ({
    name: row.name,
    trans: row.trans ? [row.trans] : [],
    usphone: row.usphone ?? '',
    ukphone: row.ukphone ?? '',
  }))
}

export function useWordList(): UseWordListResult {
  const currentDictInfo = useAtomValue(currentDictInfoAtom)
  const [currentChapter, setCurrentChapter] = useAtom(currentChapterAtom)
  const { isReviewMode, reviewRecord } = useAtomValue(reviewModeInfoAtom)
  const refreshCustom = useAtomValue(refreshCustomWordBookAtom)

  useEffect(() => {
    if (currentChapter >= currentDictInfo.chapterCount) {
      setCurrentChapter(0)
    }
  }, [currentChapter, currentDictInfo.chapterCount, setCurrentChapter])

  const isFirstChapter = !isReviewMode && currentDictInfo.id === 'cet4' && currentChapter === 0
  const fileData = useSWR(currentDictInfo.url ? currentDictInfo.url : null, wordListFetcher)
  const { data: wordList, error, isLoading } = fileData

  const dictId = currentDictInfo.id
  const isPhraseBook = dictId.includes('-Phrase')
  const curDictType = isPhraseBook ? 1 : 0
  const curDictName = isPhraseBook ? dictId.split('-Phrase')[0] : dictId

  const customWordList = useMemo(() => {
    if (currentDictInfo.languageCategory !== 'VocabularyBook') {
      return EMPTY_WORDS
    }
    const raw = localStorage.getItem('wordBookList')
    if (!raw) {
      return EMPTY_WORDS
    }
    try {
      const rows = JSON.parse(raw) as CustomWordRow[]
      return customRowsToWords(
        rows.filter((item) => item.bookName === curDictName && item.type === curDictType),
      )
    } catch {
      return EMPTY_WORDS
    }
  }, [currentDictInfo.languageCategory, curDictName, curDictType, refreshCustom])

  const words: WordWithIndex[] = useMemo(() => {
    let newWords: Word[]
    if (isFirstChapter) {
      newWords = firstChapter
    } else if (isReviewMode) {
      newWords = reviewRecord?.words ?? []
    } else if (wordList && currentDictInfo.url) {
      newWords = wordList.slice(currentChapter * CHAPTER_LENGTH, (currentChapter + 1) * CHAPTER_LENGTH)
    } else {
      newWords = customWordList.slice(currentChapter * CHAPTER_LENGTH, (currentChapter + 1) * CHAPTER_LENGTH)
    }

    return newWords.map((word, index) => {
      let trans: string[]
      if (Array.isArray(word.trans)) {
        trans = word.trans.filter((item) => typeof item === 'string')
      } else if (word.trans === null || word.trans === undefined || typeof word.trans === 'object') {
        trans = []
      } else {
        trans = [String(word.trans)]
      }
      return {
        ...word,
        index,
        trans,
      }
    })
  }, [isFirstChapter, isReviewMode, wordList, reviewRecord?.words, currentChapter, customWordList, currentDictInfo.url])

  const loading = currentDictInfo.languageCategory === 'VocabularyBook' ? false : isLoading

  return { words, isLoading: loading, error }
}

const firstChapter = [
  { name: 'cancel', trans: ['取消， 撤销； 删去'], usphone: "'kænsl", ukphone: "'kænsl" },
  { name: 'explosive', trans: ['爆炸的； 极易引起争论的', '炸药'], usphone: "ɪk'splosɪv; ɪk'splozɪv", ukphone: "ɪk'spləusɪv" },
  { name: 'numerous', trans: ['众多的'], usphone: "'numərəs", ukphone: "'njuːmərəs" },
  { name: 'govern', trans: ['居支配地位， 占优势', '统治，治理，支配'], usphone: "'ɡʌvɚn", ukphone: "'gʌvn" },
  { name: 'analyse', trans: ['分析； 分解； 解析'], usphone: "'æn(ə)laɪz", ukphone: "'ænəlaɪz" },
  { name: 'discourage', trans: ['使泄气， 使灰心； 阻止， 劝阻'], usphone: "dɪs'kɝɪdʒ", ukphone: "dɪs'kʌrɪdʒ" },
  { name: 'resemble', trans: ['像， 类似于'], usphone: "rɪ'zɛmbl", ukphone: "rɪ'zembl" },
  {
    name: 'remote',
    trans: ['遥远的； 偏僻的； 关系疏远的； 脱离的； 微乎其微的； 孤高的， 冷淡的； 遥控的'],
    usphone: "rɪ'mot",
    ukphone: "rɪ'məut",
  },
  { name: 'salary', trans: ['薪金， 薪水'], usphone: "'sæləri", ukphone: "'sæləri" },
  { name: 'pollution', trans: ['污染， 污染物'], usphone: "pə'luʃən", ukphone: "pə'luːʃn" },
  { name: 'pretend', trans: ['装作， 假装'], usphone: "prɪ'tɛnd", ukphone: "prɪ'tend" },
  { name: 'kettle', trans: ['水壶'], usphone: "'kɛtl", ukphone: "'ketl" },
  { name: 'wreck', trans: ['失事；残骸；精神或身体已垮的人', '破坏'], usphone: 'rɛk', ukphone: 'rek' },
  { name: 'drunk', trans: ['醉的； 陶醉的'], usphone: 'drʌŋk', ukphone: 'drʌŋk' },
  { name: 'calculate', trans: ['计算； 估计； 计划'], usphone: "'kælkjulet", ukphone: "'kælkjuleɪt" },
  { name: 'persistent', trans: ['坚持的， 不屈不挠的； 持续不断的； 反复出现的'], usphone: "pə'zɪstənt", ukphone: "pə'sɪstənt" },
  { name: 'sake', trans: ['缘故， 理由'], usphone: 'sek', ukphone: 'seɪk' },
  { name: 'conceal', trans: ['把…隐藏起来， 掩盖， 隐瞒'], usphone: "kən'sil", ukphone: "kən'siːl" },
  { name: 'audience', trans: ['听众， 观众， 读者'], usphone: "'ɔdɪəns", ukphone: "'ɔːdiəns" },
  { name: 'meanwhile', trans: ['与此同时'], usphone: "'minwaɪl", ukphone: "'miːnwaɪl" },
]
