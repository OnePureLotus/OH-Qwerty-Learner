import Layout from '@/components/Layout'
import {
  customWordBookListAtom,
  customWordBookListCountAtom,
  refreshCustomWordBookAtom,
} from '@/store'
import type { CustomWordRow } from '@/utils/customWordBook/types'
import {
  deleteCustomWordBook,
  deleteCustomWords,
  importDictJsonFile,
  readCustomWordList,
  syncCustomWordBookCatalog,
} from '@/utils/customWordBook/localWordBookService'
import * as ScrollArea from '@radix-ui/react-scroll-area'
import { useAtom, useSetAtom } from 'jotai'
import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useHotkeys } from 'react-hotkeys-hook'
import { useNavigate } from 'react-router-dom'
import IconX from '~icons/tabler/x'

const PAGE_SIZE = 15

export default function CustomWordBookManagePage() {
  const navigate = useNavigate()
  const uploadRef = useRef<HTMLInputElement>(null)
  const [rows, setRows] = useAtom(customWordBookListAtom)
  const setCount = useSetAtom(customWordBookListCountAtom)
  const setRefresh = useSetAtom(refreshCustomWordBookAtom)
  const [filter, setFilter] = useState('')
  const [selected, setSelected] = useState<Set<string>>(new Set())
  const [page, setPage] = useState(1)
  const [importBookName, setImportBookName] = useState('')
  const [importDescription, setImportDescription] = useState('')
  const [importing, setImporting] = useState(false)
  const [deleteBookName, setDeleteBookName] = useState('')
  const [message, setMessage] = useState('')

  const reload = useCallback(() => {
    const list = readCustomWordList()
    setRows(list)
    setCount(list.length)
    syncCustomWordBookCatalog()
    setRefresh(true)
  }, [setCount, setRefresh, setRows])

  useEffect(() => {
    reload()
  }, [reload])

  const onBack = useCallback(() => navigate('/'), [navigate])
  useHotkeys('esc', onBack, { preventDefault: true })

  const filtered = useMemo(() => {
    const q = filter.trim().toLowerCase()
    if (!q) {
      return rows
    }
    return rows.filter(
      (row) =>
        row.name.toLowerCase().includes(q) ||
        row.trans.toLowerCase().includes(q) ||
        row.bookName.toLowerCase().includes(q),
    )
  }, [filter, rows])

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE))
  const pageRows = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE)

  const bookNames = useMemo(() => {
    const set = new Set<string>()
    rows.forEach((r) => set.add(r.bookName))
    return Array.from(set)
  }, [rows])

  const toggleSelect = (id: string) => {
    setSelected((prev) => {
      const next = new Set(prev)
      if (next.has(id)) {
        next.delete(id)
      } else {
        next.add(id)
      }
      return next
    })
  }

  const toggleSelectAllOnPage = () => {
    const pageIds = pageRows.map((r) => r.id)
    const allSelected = pageIds.every((id) => selected.has(id))
    setSelected((prev) => {
      const next = new Set(prev)
      pageIds.forEach((id) => {
        if (allSelected) {
          next.delete(id)
        } else {
          next.add(id)
        }
      })
      return next
    })
  }

  const onDeleteSelected = () => {
    if (selected.size === 0) {
      setMessage('请先勾选要删除的词条')
      return
    }
    const count = selected.size
    deleteCustomWords(Array.from(selected))
    setSelected(new Set())
    reload()
    setMessage(`已删除 ${count} 条`)
  }

  const onDeleteBook = () => {
    if (!deleteBookName.trim()) {
      setMessage('请输入要删除的单词本名称')
      return
    }
    deleteCustomWordBook(deleteBookName.trim())
    setDeleteBookName('')
    reload()
    setMessage('单词本已删除')
  }

  const onImport = async (file: File) => {
    if (!importBookName.trim()) {
      setMessage('导入前请填写单词本名称')
      return
    }
    setImporting(true)
    try {
      const added = await importDictJsonFile(file, importBookName.trim(), importDescription.trim(), 0)
      reload()
      setMessage(`成功导入 ${added} 个词条`)
    } catch (e) {
      setMessage(e instanceof Error ? e.message : '导入失败')
    } finally {
      setImporting(false)
      if (uploadRef.current) {
        uploadRef.current.value = ''
      }
    }
  }

  return (
    <Layout>
      <div className="relative mx-auto flex h-full w-full max-w-6xl flex-col px-6 py-8">
        <IconX className="absolute right-6 top-6 h-7 w-7 cursor-pointer text-gray-400" onClick={onBack} />
        <h1 className="mb-2 text-2xl font-bold text-gray-800 dark:text-gray-100">自定义词库管理</h1>
        <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">
          数据保存在本机 WebView（localStorage），格式见{' '}
          <a
            className="text-indigo-500 underline"
            href="https://github.com/RealKai42/qwerty-learner/blob/master/docs/toBuildDict.md"
            target="_blank"
            rel="noreferrer"
          >
            toBuildDict.md
          </a>
          。支持 JSON 数组导入。
        </p>

        {message && (
          <div className="mb-3 rounded-md bg-indigo-50 px-3 py-2 text-sm text-indigo-800 dark:bg-indigo-900/40 dark:text-indigo-100">
            {message}
          </div>
        )}

        <div className="mb-4 flex flex-wrap items-end gap-3 rounded-lg border border-gray-200 p-4 dark:border-gray-700">
          <div className="flex min-w-[160px] flex-col gap-1">
            <label className="text-xs text-gray-500">单词本名称</label>
            <input
              className="rounded border px-2 py-1 dark:border-gray-600 dark:bg-gray-900"
              value={importBookName}
              onChange={(e) => setImportBookName(e.target.value)}
              placeholder="例如：我的考研词"
            />
          </div>
          <div className="flex min-w-[200px] flex-1 flex-col gap-1">
            <label className="text-xs text-gray-500">描述</label>
            <input
              className="rounded border px-2 py-1 dark:border-gray-600 dark:bg-gray-900"
              value={importDescription}
              onChange={(e) => setImportDescription(e.target.value)}
              placeholder="选填"
            />
          </div>
          <input
            ref={uploadRef}
            type="file"
            accept=".json,application/json"
            className="hidden"
            onChange={(e) => {
              const file = e.target.files?.[0]
              if (file) {
                onImport(file)
              }
            }}
          />
          <button
            type="button"
            disabled={importing}
            className="rounded bg-indigo-500 px-4 py-2 text-sm text-white disabled:opacity-50"
            onClick={() => uploadRef.current?.click()}
          >
            {importing ? '导入中…' : '导入 JSON 词书'}
          </button>
          <button
            type="button"
            className="rounded border border-indigo-500 px-4 py-2 text-sm text-indigo-600 dark:text-indigo-300"
            onClick={() => navigate('/custom-wordbook/add')}
          >
            添加单词
          </button>
        </div>

        <div className="mb-3 flex flex-wrap gap-2">
          <input
            className="min-w-[200px] flex-1 rounded border px-2 py-1 dark:border-gray-600 dark:bg-gray-900"
            placeholder="搜索单词 / 释义 / 单词本"
            value={filter}
            onChange={(e) => {
              setFilter(e.target.value)
              setPage(1)
            }}
          />
          <button type="button" className="rounded bg-red-500 px-3 py-1 text-sm text-white" onClick={onDeleteSelected}>
            删除选中
          </button>
          <select
            className="rounded border px-2 py-1 dark:border-gray-600 dark:bg-gray-900"
            value={deleteBookName}
            onChange={(e) => setDeleteBookName(e.target.value)}
          >
            <option value="">选择要删除的整本词书</option>
            {bookNames.map((name) => (
              <option key={name} value={name}>
                {name}
              </option>
            ))}
          </select>
          <button type="button" className="rounded border border-red-400 px-3 py-1 text-sm text-red-600" onClick={onDeleteBook}>
            删除整本
          </button>
        </div>

        <ScrollArea.Root className="flex-1 overflow-hidden rounded-lg border dark:border-gray-700">
          <ScrollArea.Viewport className="max-h-[55vh] w-full">
            <table className="w-full text-left text-sm">
              <thead className="sticky top-0 bg-gray-100 dark:bg-gray-800">
                <tr>
                  <th className="p-2">
                    <input type="checkbox" onChange={toggleSelectAllOnPage} aria-label="全选本页" />
                  </th>
                  <th className="p-2">单词</th>
                  <th className="p-2">释义</th>
                  <th className="p-2">单词本</th>
                  <th className="p-2">操作</th>
                </tr>
              </thead>
              <tbody>
                {pageRows.map((row: CustomWordRow) => (
                  <tr key={row.id} className="border-t dark:border-gray-700">
                    <td className="p-2">
                      <input type="checkbox" checked={selected.has(row.id)} onChange={() => toggleSelect(row.id)} />
                    </td>
                    <td className="p-2 font-medium">{row.name}</td>
                    <td className="p-2 text-gray-600 dark:text-gray-300">{row.trans}</td>
                    <td className="p-2">{row.bookName}</td>
                    <td className="p-2">
                      <button
                        type="button"
                        className="text-red-500"
                        onClick={() => {
                          deleteCustomWords([row.id])
                          reload()
                        }}
                      >
                        删除
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </ScrollArea.Viewport>
        </ScrollArea.Root>

        <div className="mt-3 flex items-center justify-between text-sm text-gray-600 dark:text-gray-400">
          <span>
            共 {filtered.length} 条 · 第 {page} / {totalPages} 页
          </span>
          <div className="flex gap-2">
            <button type="button" className="rounded border px-2 py-1" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>
              上一页
            </button>
            <button
              type="button"
              className="rounded border px-2 py-1"
              disabled={page >= totalPages}
              onClick={() => setPage((p) => p + 1)}
            >
              下一页
            </button>
          </div>
        </div>
      </div>
    </Layout>
  )
}
