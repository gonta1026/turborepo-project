import type React from 'react'
import { useId, useState } from 'react'

export const Counter: React.FC = () => {
  const [count, setCount] = useState(0)
  const id = useId()

  return (
    <button id={id} type="button" onClick={() => setCount(count + 1)}>
      {count}
    </button>
  )
}
