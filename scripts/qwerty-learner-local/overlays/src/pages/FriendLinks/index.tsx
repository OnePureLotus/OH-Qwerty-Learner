import Layout from '../../components/Layout'
import qwertyLogo from '@/assets/qwerty-logo.svg'
import type React from 'react'

export const FriendLinks: React.FC = () => {
  const links = [
    {
      title: 'RealKai42 / qwerty-learner',
      href: 'https://github.com/RealKai42/qwerty-learner',
      imgSrc: qwertyLogo,
      description:
        '原版 Web 打字背单词项目。本应用内置其前端资源（词库、练习流程、音标与统计），通过 ArkWeb 本地打包与虚拟域名加载，不依赖在线官网。',
    },
    {
      title: 'likaia / qwerty-learner',
      href: 'https://github.com/likaia/qwerty-learner',
      imgSrc: qwertyLogo,
      description:
        '社区二开参考。自定义词书管理（JSON 导入、词条维护）等交互借鉴其 master_wordbook_manage 思路；本应用无登录、无后端，数据保存在 WebView localStorage。',
    },
  ]

  return (
    <Layout>
      <div className="flex w-full flex-1 flex-col items-center px-4 pt-20">
        <div className="flex w-full max-w-md flex-grow flex-col items-center">
          <div className="mt-5 text-center text-lg font-bold dark:text-gray-50">上游仓库</div>
          <p className="mt-2 px-2 text-center text-xs text-gray-500 dark:text-gray-400">
            {`OH QwertyLearner 在 HarmonyOS 上移植并离线化，下列为直接参考的开源项目。`}
          </p>
          <div className="links flex w-full flex-col items-center gap-y-8 py-5">
            {links.map((link, index) => (
              <a
                key={index}
                title={link.title}
                href={link.href}
                target="_blank"
                rel="noopener noreferrer"
                className="linkItem flex w-full items-center overflow-hidden dark:text-gray-50"
              >
                <div className="mr-3 flex h-8 w-8 flex-shrink-0 items-center justify-center bg-gray-200">
                  <img src={link.imgSrc} alt={link.title} className="h-full w-full object-contain p-0.5" />
                </div>
                <div className="flex-1">
                  <div className="pb-1 text-sm font-bold">{link.title}</div>
                  <div className="text-xs text-gray-500 dark:text-gray-400">{link.description}</div>
                </div>
              </a>
            ))}
          </div>
        </div>
      </div>
    </Layout>
  )
}
