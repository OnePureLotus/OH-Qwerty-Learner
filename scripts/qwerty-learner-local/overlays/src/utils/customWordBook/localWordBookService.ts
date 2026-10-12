import type { CustomWordBookCount, CustomWordRow, CustomWordType, ImportDictJsonEntry } from './types'
import type { DictionaryResource } from '@/typings'
import { calcChapterCount } from '@/utils'

const WORD_BOOK_LIST_KEY = 'wordBookList'
const REMOTE_CLASSIFIED_KEY = 'remoteClassifiedData'

function nowString(): string {
  const d = new Date()
  const pad = (n: number): string => n.toString().padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
}

function newId(): string {
  return `local-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`
}

function normalizeTrans(trans: string[] | string | undefined): string {
  if (trans === undefined || trans === null) {
    return ''
  }
  if (Array.isArray(trans)) {
    return trans.filter((t) => typeof t === 'string').join('；')
  }
  return String(trans)
}

export function readCustomWordList(): CustomWordRow[] {
  const raw = localStorage.getItem(WORD_BOOK_LIST_KEY)
  if (!raw) {
    return []
  }
  try {
    const parsed = JSON.parse(raw) as CustomWordRow[]
    return Array.isArray(parsed) ? parsed : []
  } catch {
    return []
  }
}

export function writeCustomWordList(rows: CustomWordRow[]): void {
  localStorage.setItem(WORD_BOOK_LIST_KEY, JSON.stringify(rows))
}

function countByBook(rows: CustomWordRow[]): CustomWordBookCount[] {
  const names = new Set<string>()
  rows.forEach((row) => {
    if (row.bookName) {
      names.add(row.bookName)
    }
  })
  const result: CustomWordBookCount[] = []
  names.forEach((name) => {
    let totalWordCount = 0
    let totalPhraseCount = 0
    rows.forEach((row) => {
      if (row.bookName !== name) {
        return
      }
      if (row.type === 1) {
        totalPhraseCount++
      } else {
        totalWordCount++
      }
    })
    result.push({ name, totalWordCount, totalPhraseCount })
  })
  return result
}

export function buildClassifiedDictResources(rows: CustomWordRow[]): DictionaryResource[] {
  const counts = countByBook(rows)
  const seen: Record<string, boolean> = {}
  const result: DictionaryResource[] = []

  rows.forEach((item) => {
    const countInfo = counts.find((c) => c.name === item.bookName)
    const totalWordCount = countInfo?.totalWordCount ?? 0
    const totalPhraseCount = countInfo?.totalPhraseCount ?? 0
    const bookNameWithPhrase = item.type === 1 ? `${item.bookName} Phrase` : item.bookName
    const dictId = item.type === 1 ? `${item.bookName}-Phrase` : item.bookName
    const key = `${bookNameWithPhrase}::${item.description ?? ''}`
    if (seen[key]) {
      return
    }
    const length = item.type === 1 ? totalPhraseCount : totalWordCount
    result.push({
      id: dictId,
      name: bookNameWithPhrase,
      description: item.description ?? '自定义词书',
      category: '自定义词书',
      tags: item.type === 1 ? ['短语'] : ['单词'],
      url: '',
      length,
      language: 'en',
      languageCategory: 'VocabularyBook',
    })
    seen[key] = true
  })
  return result
}

export function syncCustomWordBookCatalog(): DictionaryResource[] {
  const rows = readCustomWordList()
  const classified = buildClassifiedDictResources(rows)
  localStorage.setItem(REMOTE_CLASSIFIED_KEY, JSON.stringify(classified))
  return classified
}

export function findCustomDictResource(dictId: string): DictionaryResource | undefined {
  const raw = localStorage.getItem(REMOTE_CLASSIFIED_KEY)
  if (!raw) {
    return undefined
  }
  try {
    const list = JSON.parse(raw) as DictionaryResource[]
    return list.find((item) => item.id === dictId)
  } catch {
    return undefined
  }
}

export function addCustomWord(input: {
  name: string
  trans: string
  usphone?: string
  ukphone?: string
  bookName: string
  description?: string
  type: CustomWordType
}): CustomWordRow {
  const rows = readCustomWordList()
  const row: CustomWordRow = {
    id: newId(),
    name: input.name.trim(),
    trans: input.trans.trim(),
    usphone: input.usphone?.trim(),
    ukphone: input.ukphone?.trim(),
    bookName: input.bookName.trim(),
    description: input.description?.trim(),
    type: input.type,
    createTime: nowString(),
  }
  rows.push(row)
  writeCustomWordList(rows)
  syncCustomWordBookCatalog()
  return row
}

export function deleteCustomWords(ids: string[]): void {
  const idSet = new Set(ids)
  const rows = readCustomWordList().filter((row) => !idSet.has(row.id))
  writeCustomWordList(rows)
  syncCustomWordBookCatalog()
}

export function deleteCustomWordBook(bookName: string): void {
  const rows = readCustomWordList().filter((row) => row.bookName !== bookName)
  writeCustomWordList(rows)
  syncCustomWordBookCatalog()
}

export function importDictJsonFile(
  file: File,
  bookName: string,
  description: string,
  wordType: CustomWordType = 0,
): Promise<number> {
  return new Promise((resolve, reject) => {
    const maxSize = 3 * 1024 * 1024
    if (file.size > maxSize) {
      reject(new Error('文件必须小于 3MB'))
      return
    }
    const reader = new FileReader()
    reader.onload = () => {
      try {
        const text = String(reader.result ?? '')
        const parsed = JSON.parse(text) as ImportDictJsonEntry[]
        if (!Array.isArray(parsed)) {
          reject(new Error('JSON 格式应为数组，请参考 docs/toBuildDict.md'))
          return
        }
        const rows = readCustomWordList()
        const trimmedBook = bookName.trim()
        const trimmedDesc = description.trim()
        let added = 0
        parsed.forEach((entry) => {
          if (!entry?.name) {
            return
          }
          rows.push({
            id: newId(),
            name: String(entry.name).trim(),
            trans: normalizeTrans(entry.trans),
            usphone: entry.usphone?.trim(),
            ukphone: entry.ukphone?.trim(),
            bookName: trimmedBook,
            description: trimmedDesc,
            type: wordType,
            createTime: nowString(),
          })
          added++
        })
        if (added === 0) {
          reject(new Error('未解析到有效词条'))
          return
        }
        writeCustomWordList(rows)
        syncCustomWordBookCatalog()
        resolve(added)
      } catch (e) {
        reject(e instanceof Error ? e : new Error('JSON 解析失败'))
      }
    }
    reader.onerror = () => reject(new Error('读取文件失败'))
    reader.readAsText(file, 'utf-8')
  })
}

export function listCustomBookNames(): string[] {
  const names = new Set<string>()
  readCustomWordList().forEach((row) => {
    if (row.bookName) {
      names.add(row.bookName)
    }
  })
  return Array.from(names)
}
