import { sigil, reactRenderer } from '@tlon/sigil-js'

export const formatShip = (ship: string) =>
  ship.length > 26 ? `${ship.slice(0, 6)}_${ship.slice(-6)}` :
  ship.length > 14 ? `~${ship.slice(-13, -7)}^${ship.slice(-6)}` :
  ship

export interface RenderSigilProps {
  ship: string
  alt?: boolean
  className?: string
  size?: number
}

export const renderSigil = ({ ship, alt = false, className = '', size = 24 }: RenderSigilProps) => {
  if (ship.length > 14) {
    return <div className={className} style={{ height: size, width: size, background: 'black', borderRadius: 2 }} />
  }

  return sigil({ patp: ship, renderer: reactRenderer, size, class: className, colors: alt ? ['white', 'black'] : ['black', 'white'] })
}
