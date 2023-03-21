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
  const cleanShip = ship.replace('~', '')
  const first = cleanShip[0]?.toUpperCase()
  const fourth = cleanShip[3]?.toUpperCase()
  const seventh = cleanShip[7]?.toUpperCase()
  const tenth = cleanShip[10]?.toUpperCase()

  const [back, fore] = colors || (alt ? ['white', 'black'] : ['black', 'white'])

  const isMoon = ship.length > 14

  return (
    <div className='avatar-sigil' style={{
      height: size,
      width: size,
      backgroundColor: back || 'black',
      padding: 4,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      position: 'relative',
    }}>
      <div style={{ display: 'flex', flexDirection: 'row', justifyContent: 'space-around', width: '100%' }}>
        <div style={{ fontSize: size / 3, fontWeight: '600', color: fore }}>{first}</div>
        {Boolean(fourth) && <div style={{ fontSize: size / 3, fontWeight: '600', color: fore }}>{fourth}</div>}
      </div>
      {Boolean(seventh && tenth) && (
        <div style={{ display: 'flex', flexDirection: 'row', justifyContent: 'space-around', width: '100%' }}>
          <div style={{ fontSize: size / 3, fontWeight: '600', color: fore }}>{seventh}</div>
          <div style={{ fontSize: size / 3, fontWeight: '600', color: fore }}>{tenth}</div>
        </div>
      )}
      {isMoon && (
        <div style={{
          backgroundColor: 'white',
          height: size / 6,
          width: size / 6,
          position: 'absolute',
          alignSelf: 'center',
          borderRadius: size / 6,
          top: size / 2 - size / 12,
        }} />
      )}
    </div>
  )
  // if (ship.length > 14) {
  //   return <div className={className} style={{ height: size, width: size, background: 'black', borderRadius: 2 }} />
  // }

  // return sigil({ patp: ship, renderer: reactRenderer, size, class: className, colors: colors || (alt ? ['white', 'black'] : ['black', 'white']) })
}
