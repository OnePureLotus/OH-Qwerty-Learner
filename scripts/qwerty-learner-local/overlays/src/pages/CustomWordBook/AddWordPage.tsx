import Layout from '@/components/Layout'
import { defaultCustomWordBookIdAtom, refreshCustomWordBookAtom } from '@/store'
import type { CustomWordType } from '@/utils/customWordBook/types'
import { addCustomWord, listCustomBookNames } from '@/utils/customWordBook/localWordBookService'
import { useAtom, useSetAtom } from 'jotai'
import { useCallback, useEffect, useState } from 'react'
import { useHotkeys } from 'react-hotkeys-hook'
import { useNavigate } from 'react-router-dom'
import IconX from '~icons/tabler/x'

export default function CustomWordBookAddPage() {
  const navigate = useNavigate()
  const [defaultBook, setDefaultBook] = useAtom(defaultCustomWordBookIdAtom)
  const setRefresh = useSetAtom(refreshCustomWordBookAtom)
  const [bookOptions, setBookOptions] = useState<string[]>([])
  const [bookName, setBookName] = useState(defaultBook)
  const [description, setDescription] = useState('')
  const [name, setName] = useState('')
  const [trans, setTrans] = useState('')
  const [usphone, setUsphone] = useState('')
  const [ukphone, setUkphone] = useState('')
  const [wordType, setWordType] = useState<CustomWordType>(0)
  const [message, setMessage] = useState('')

  const reloadOptions = useCallback(() => {
    const names = listCustomBookNames()
    setBookOptions(names)
    if (!bookName && names.length > 0) {
      setBookName(names[0])
    }
  }, [bookName])

  useEffect(() => {
    reloadOptions()
  }, [reloadOptions])

  const onBack = useCallback(() => navigate('/'), [navigate])
  useHotkeys('esc', onBack, { preventDefault: true })

  const onSave = () => {
    if (!bookName.trim() || !name.trim() || !trans.trim()) {
      setMessage('请填写单词本名称、单词和释义')
      return
    }
    addCustomWord({
      bookName: bookName.trim(),
      description: description.trim() || '自定义词书',
      name: name.trim(),
      trans: trans.trim(),
      usphone: usphone.trim(),
      ukphone: ukphone.trim(),
      type: wordType,
    })
    setDefaultBook(bookName.trim())
    setRefresh(true)
    setName('')
    setTrans('')
    setUsphone('')
    setUkphone('')
    setMessage('添加成功')
    reloadOptions()
  }

  return (
    <Layout>
      <div className="relative mx-auto flex w-full max-w-xl flex-col px-6 py-8">
        <IconX className="absolute right-6 top-6 h-7 w-7 cursor-pointer text-gray-400" onClick={onBack} />
        <h1 className="mb-4 text-2xl font-bold">添加单词</h1>
        {message && <p className="mb-3 text-sm text-indigo-600 dark:text-indigo-300">{message}</p>}

        <label className="mb-1 text-sm text-gray-500">单词本（可输入新名称）</label>
        <input
          list="custom-book-names"
          className="mb-3 rounded border px-3 py-2 dark:border-gray-600 dark:bg-gray-900"
          value={bookName}
          onChange={(e) => setBookName(e.target.value)}
        />
        <datalist id="custom-book-names">
          {bookOptions.map((n) => (
            <option key={n} value={n} />
          ))}
        </datalist>

        <label className="mb-1 text-sm text-gray-500">单词本描述</label>
        <input
          className="mb-3 rounded border px-3 py-2 dark:border-gray-600 dark:bg-gray-900"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />

        <label className="mb-1 text-sm text-gray-500">类型</label>
        <select
          className="mb-3 rounded border px-3 py-2 dark:border-gray-600 dark:bg-gray-900"
          value={wordType}
          onChange={(e) => setWordType(Number(e.target.value) as CustomWordType)}
        >
          <option value={0}>单词</option>
          <option value={1}>短语</option>
        </select>

        <label className="mb-1 text-sm text-gray-500">单词 / 短语</label>
        <input
          className="mb-3 rounded border px-3 py-2 dark:border-gray-600 dark:bg-gray-900"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />

        <label className="mb-1 text-sm text-gray-500">中文释义</label>
        <textarea
          className="mb-3 rounded border px-3 py-2 dark:border-gray-600 dark:bg-gray-900"
          rows={3}
          value={trans}
          onChange={(e) => setTrans(e.target.value)}
        />

        <label className="mb-1 text-sm text-gray-500">美音音标（选填）</label>
        <input
          className="mb-3 rounded border px-3 py-2 dark:border-gray-600 dark:bg-gray-900"
          value={usphone}
          onChange={(e) => setUsphone(e.target.value)}
        />

        <label className="mb-1 text-sm text-gray-500">英音音标（选填）</label>
        <input
          className="mb-3 rounded border px-3 py-2 dark:border-gray-600 dark:bg-gray-900"
          value={ukphone}
          onChange={(e) => setUkphone(e.target.value)}
        />

        <button type="button" className="mt-2 rounded bg-indigo-500 px-4 py-2 text-white" onClick={onSave}>
          保存
        </button>
      </div>
    </Layout>
  )
}
