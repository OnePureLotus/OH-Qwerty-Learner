import Tooltip from '@/components/Tooltip'
import { useNavigate } from 'react-router-dom'
import IconBooks from '~icons/tabler/books'

export default function CustomWordBookButton() {
  const navigate = useNavigate()
  return (
    <Tooltip className="h-7 w-7" content="自定义词库">
      <button
        type="button"
        className="p-[2px] text-lg text-indigo-500 focus:outline-none"
        aria-label="自定义词库"
        onClick={(e) => {
          navigate('/custom-wordbook/manage')
          e.currentTarget.blur()
        }}
      >
        <IconBooks />
      </button>
    </Tooltip>
  )
}
