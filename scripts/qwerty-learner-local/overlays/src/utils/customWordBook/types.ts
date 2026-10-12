export type CustomWordType = 0 | 1

/** Local custom word row (compatible with likaia wordBookList storage shape). */
export type CustomWordRow = {
  id: string
  name: string
  trans: string
  usphone?: string
  ukphone?: string
  bookName: string
  description?: string
  type: CustomWordType
  createTime?: string
}

export type CustomWordBookCount = {
  name: string
  totalWordCount: number
  totalPhraseCount: number
}

export type ImportDictJsonEntry = {
  name: string
  trans: string[] | string
  usphone?: string
  ukphone?: string
}
