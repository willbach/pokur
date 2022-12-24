import { sigil, reactRenderer } from '@tlon/sigil-js'

export const formatShip = (ship: string) => {
  const clean = ship.replace('~', '')

  return '~' + (clean.length > 28 ? `${clean.slice(0, 7)}_${clean.slice(-6)}` :
    clean.length > 14 ? `${clean.slice(-13, -7)}^${clean.slice(-6)}` :
    ship)
}

export const renderShip = (ship: string) => {
  const clean = ship.replace('~', '')

  if (clean.length > 14) {
    return <>
      <span style={{ fontSize: 11, verticalAlign: 'top' }}>~{clean.slice(0, 13)}</span>
      ^{clean.slice(14)}
    </>
  }

  return '~' + (clean.length > 28 ? `${clean.slice(0, 7)}_${clean.slice(-6)}` : clean)
}

export interface RenderSigilProps {
  ship: string
  alt?: boolean
  className?: string
  size?: number
  colors?: [string, string]
}

export const renderSigil = ({ ship, alt = false, className = '', size = 24, colors }: RenderSigilProps) => {
  if (ship.length > 14) {
    return <div className={className} style={{ height: size, width: size, background: 'black', borderRadius: 2 }} />
  }

  return sigil({ patp: ship, renderer: reactRenderer, size, class: className, colors: colors || (alt ? ['white', 'black'] : ['black', 'white']) })
}
