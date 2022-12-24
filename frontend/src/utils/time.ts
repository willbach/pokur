import { ONE_SECOND } from "./constants"

export const getHoonDate = (d: Date) => `~${d.getFullYear()}.${d.getMonth()}.${d.getDate()}..${d.getHours()}.${d.getMinutes()}.${d.getSeconds()}..${d.getMilliseconds().toString(16)}`

export const hoonToJSDate = (hoonDate: string) => {
  // "2015-03-25T12:00:00Z"
  const [date, time, ms] = hoonDate.slice(1).split('..')
  const isoDate = `${date.replace(/\./g, '-')}T${time.replace(/\./g, ':')}.${parseInt(ms, 16)}Z`
  return new Date(isoDate)
}

export const getHoonSeconds = (increment: string) => Number(increment.slice(2)) * (increment.includes('~m') ? 60 : 1)

export const getSecondsFromNow = (hoonDate?: string, increment?: string) =>
  hoonDate === undefined || increment === undefined ? 0 :
  Math.floor(
    ((hoonToJSDate(hoonDate).getTime() + ONE_SECOND * getHoonSeconds(increment))  - new Date().getTime()) / ONE_SECOND
  )
