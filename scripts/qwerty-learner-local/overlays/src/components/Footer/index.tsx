import InfoPanel from '@/components/InfoPanel'
import qqGroupPlaceholder from '@/assets/qq-group-placeholder.jpg'
import { infoPanelStateAtom } from '@/store'
import type { InfoPanelType } from '@/typings'
import { recordOpenInfoPanelAction } from '@/utils'
import { useAtom } from 'jotai'
import type React from 'react'
import { useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import RiLinksLine from '~icons/ri/links-line'
import IconGithub from '~icons/simple-icons/github'
import IconQq from '~icons/simple-icons/tencentqq'

const GITHUB_REPO = 'https://github.com/OnePureLotus/OH-Qwerty-Learner'
const APP_DISPLAY_NAME = 'OH QwertyLearner'

const Footer: React.FC = () => {
  const [infoPanelState, setInfoPanelState] = useAtom(infoPanelStateAtom)
  const navigate = useNavigate()

  const handleOpenInfoPanel = useCallback(
    (modalType: InfoPanelType) => {
      recordOpenInfoPanelAction(modalType, 'footer')
      setInfoPanelState((state) => ({ ...state, [modalType]: true }))
    },
    [setInfoPanelState],
  )

  const handleCloseInfoPanel = useCallback(
    (modalType: InfoPanelType) => {
      setInfoPanelState((state) => ({ ...state, [modalType]: false }))
    },
    [setInfoPanelState],
  )

  return (
    <>
      <InfoPanel
        openState={infoPanelState.community}
        title="QQ 用户群"
        icon={IconQq}
        buttonClassName="bg-sky-500 hover:bg-sky-400"
        iconClassName="text-sky-500 bg-sky-100 dark:text-sky-300 dark:bg-sky-500"
        onClose={() => handleCloseInfoPanel('community')}
      >
        <p className="text-sm text-gray-500 dark:text-gray-400">
          {APP_DISPLAY_NAME} 基于开源 Qwerty Learner 移植到 HarmonyOS，在本地 ArkWeb 中离线运行。
          扫码加入 QQ 群获取更新与交流（二维码占位，后续替换为正式 QQ 群码）。
        </p>
        <br />
        <img className="ml-1 w-2/6 rounded" src={qqGroupPlaceholder} alt="QQ 群二维码占位" />
        <br />
      </InfoPanel>

      <footer className="mb-1 mt-4 flex w-full items-center justify-center gap-2.5 text-sm ease-in" onClick={(e) => e.currentTarget.blur()}>
        <a href={GITHUB_REPO} target="_blank" rel="noreferrer" aria-label="前往 GitHub 仓库">
          <IconGithub fontSize={15} className="text-gray-500 hover:text-gray-800 dark:text-gray-400 dark:hover:text-gray-100" />
        </a>

        <button
          className="cursor-pointer focus:outline-none"
          type="button"
          onClick={(e) => {
            handleOpenInfoPanel('community')
            e.currentTarget.blur()
          }}
          aria-label="加入 QQ 用户群"
        >
          <IconQq fontSize={16} className="text-gray-500 hover:text-sky-500 dark:text-gray-400 dark:hover:text-sky-400" />
        </button>

        <button
          className="cursor-pointer focus:outline-none"
          type="button"
          onClick={() => navigate('/friend-links')}
          aria-label="查看上游仓库"
        >
          <RiLinksLine fontSize={14} className="text-gray-500 hover:text-indigo-400 dark:text-gray-400 dark:hover:text-indigo-400" />
        </button>

        <span className="cursor-default text-gray-500 dark:text-gray-400">@ {APP_DISPLAY_NAME}</span>

        <span className="select-none rounded bg-slate-200 px-1 text-xs text-slate-600 dark:bg-slate-800 dark:text-slate-400">
          v{OH_APP_VERSION}
        </span>
      </footer>
    </>
  )
}

export default Footer
