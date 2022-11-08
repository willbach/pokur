// React.HTMLProps<HTMLButtonElement>
import React from 'react'
import './Button.scss'

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: string
}

const Button: React.FC<ButtonProps> = ({
  variant,
  ...props
}) => {
  const onClick = (e: any) => {
    if (!props.disabled && props.onClick)
      props.onClick(e)
  }

  return (
    <button {...props} className={`button ${props.className || ''} ${variant || ''}`} onClick={onClick}>
      {props.children}
    </button>
  )
}

export default Button
