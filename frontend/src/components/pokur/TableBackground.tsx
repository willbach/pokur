export default function TableBackground() {
  return (
    <svg className='table-background' xmlns='http://www.w3.org/2000/svg'
      style={{
        position: 'absolute',
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        background: 'radial-gradient(circle at center, #f2b463 0, #c97b0d)',
        backgroundSize: 'cover',
        height: '100%',
        width: '100%',
      }}
    >
      <filter id='noiseFilter'>
        <feTurbulence 
          type='fractalNoise'
          baseFrequency='0.95' 
          numOctaves='0.5'
          stitchTiles='stitch' />
      </filter>
      <rect width='100%' height='100%' filter='url(#noiseFilter)' />
    </svg>
  )
}
