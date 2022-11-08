const TIME_LIMIT_UNITS: { [key: string]: string } = {
  m: 'minute',
  s: 'second'
}

export const removeDots = (s: string) => (s || '').replace(/\./g, '')

export const formatHash = (hash: string) => `${removeDots(hash).slice(0, 10)}...${removeDots(hash).slice(-8)}`

export const capitalize = (word?: string) => !word ? word : word[0].toUpperCase() + word.slice(1).toLowerCase()

export const addHexPrefix = (s: string) => `0x${s.replace(/^0x/i, '')}`

export const capitalizeSpine = (s?: string) => capitalize(s)?.replace(/-[a-z]/g, m => ` ${m.slice(1).toUpperCase()}`)

export const formatTimeLimit = (tl: string) => `${tl.slice(2)} ${TIME_LIMIT_UNITS[tl.slice(1,2)]}${tl.slice(2) === '1' ? '' : 's'}`
