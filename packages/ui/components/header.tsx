import type React from 'react'
import { useId } from 'react'

interface HeaderProps {
  title: string
}

export const Header: React.FC<HeaderProps> = ({ title }) => {
  const id = useId()

  return (
    <header id={id}>
      <h1>{title}</h1>
    </header>
  )
}
