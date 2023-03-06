export const POKUR_ESCROW_CONTRACT = '0x8049.9882.0176.acbf.f6d8.c766.c30a.6900.4e24.757c.17f7.1dd1.3156.93fe.a962.2f76'
export const CASH_CHIPS_PER_TOKEN = 1000

export const SUIT_DISPLAY = {
  spades: ["♠︎", "black"], 
  hearts: ["♥︎", "red"], 
  clubs: ["♣︎", "green"], 
  diamonds: ["♦︎", "blue"]
}

export const VAL_DISPLAY: { [key: string]: string } = {
  2: '2',
  3: '3',
  4: '4',
  5: '5',
  6: '6',
  7: '7',
  8: '8',
  9: '9',
  10: '10',
  jack: 'J',
  queen: 'Q',
  king: 'K',
  ace: 'A',
}

export const SNG_BLINDS = [{ small: 15, big: 30 }, { small: 25, big: 50 }, { small: 50, big: 100 }, { small: 100, big: 200 }, { small: 200, big: 400 }]

// the key is the player/number of players and the value is where on the table the player will be placed
export const PLAYER_POSITIONS: { [key: string]: string } = {
  '12': 'pp-3',
  '22': 'pp-8',

  '13': 'pp-4',
  '23': 'pp-7',
  '33': 'pp-9',

  '14': 'pp-4',
  '24': 'pp-7',
  '34': 'pp-9',
  '44': 'pp-2',

  '15': 'pp-5',
  '25': 'pp-7',
  '35': 'pp-9',
  '45': 'pp-1',
  '55': 'pp-3',

  '16': 'pp-5',
  '26': 'pp-6',
  '36': 'pp-8',
  '46': 'pp-10',
  '56': 'pp-1',
  '66': 'pp-3',

  '17': 'pp-5',
  '27': 'pp-6',
  '37': 'pp-7',
  '47': 'pp-9',
  '57': 'pp-10',
  '67': 'pp-1',
  '77': 'pp-3',

  '18': 'pp-5',
  '28': 'pp-6',
  '38': 'pp-7',
  '48': 'pp-9',
  '58': 'pp-10',
  '68': 'pp-1',
  '78': 'pp-2',
  '88': 'pp-4',

  '19': 'pp-5',
  '29': 'pp-6',
  '39': 'pp-7',
  '49': 'pp-9',
  '59': 'pp-10',
  '69': 'pp-1',
  '79': 'pp-2',
  '89': 'pp-3',
  '99': 'pp-4',

  '110': 'pp-5',
  '210': 'pp-6',
  '310': 'pp-7',
  '410': 'pp-8',
  '510': 'pp-9',
  '610': 'pp-10',
  '710': 'pp-1',
  '810': 'pp-2',
  '910': 'pp-3',
  '1010': 'pp-4',
}

// the key is the player/number of players and the value is where on the table the player will be placed
export const MOBILE_PLAYER_POSITIONS: { [key: string]: string } = {
  '12': 'pp-3',
  '22': 'pp-8',

  '13': 'pp-3',
  '23': 'pp-7',
  '33': 'pp-9',

  '14': 'pp-2',
  '24': 'pp-4',
  '34': 'pp-7',
  '44': 'pp-9',

  '15': 'pp-3',
  '25': 'pp-5',
  '35': 'pp-7',
  '45': 'pp-9',
  '55': 'pp-1',
  
  '16': 'pp-3',
  '26': 'pp-5',
  '36': 'pp-6',
  '46': 'pp-8',
  '56': 'pp-10',
  '66': 'pp-1',

  '17': 'pp-3',
  '27': 'pp-5',
  '37': 'pp-6',
  '47': 'pp-7',
  '57': 'pp-9',
  '67': 'pp-10',
  '77': 'pp-3',

  '18': 'pp-2',
  '28': 'pp-4',
  '38': 'pp-5',
  '48': 'pp-6',
  '58': 'pp-7',
  '68': 'pp-9',
  '78': 'pp-10',
  '88': 'pp-1',

  '19': 'pp-3',
  '29': 'pp-4',
  '39': 'pp-5',
  '49': 'pp-6',
  '59': 'pp-7',
  '69': 'pp-9',
  '79': 'pp-10',
  '89': 'pp-1',
  '99': 'pp-2',

  '110': 'pp-3',
  '210': 'pp-4',
  '310': 'pp-5',
  '410': 'pp-6',
  '510': 'pp-7',
  '610': 'pp-8',
  '710': 'pp-9',
  '810': 'pp-10',
  '910': 'pp-1',
  '1010': 'pp-2',
}

export const DEFAULT_HOST_DEV = '~zod'
export const DEFAULT_HOST_PROD = '~somleg-tirsub-hodzod-walrus'
export const ONE_SECOND = 1000

export const TURN_TIMES = [
  { display: '10 seconds', value: '~s10' },
  { display: '12 seconds', value: '~s12' },
  { display: '15 seconds', value: '~s15' },
  { display: '18 seconds', value: '~s18' },
  { display: '20 seconds', value: '~s20' },
  { display: '30 seconds', value: '~s30' },
  { display: '40 seconds', value: '~s40' },
  { display: '50 seconds', value: '~s50' },
  { display: '60 seconds', value: '~s60' },
]

export const ROUND_TIMES = [
  { display: '1 minutes', value: '~m1' },
  { display: '2 minutes', value: '~m2' },
  { display: '3 minutes', value: '~m3' },
  { display: '4 minutes', value: '~m4' },
  { display: '5 minutes', value: '~m5' },
  { display: '6 minutes', value: '~m6' },
  { display: '7 minutes', value: '~m7' },
  { display: '8 minutes', value: '~m8' },
]

export const BUY_INS = [ 50, 75, 100, 125, 150, 175, 200 ]

export const NUMBER_OF_PLAYERS = [2, 3, 4, 5, 6, 7, 8, 9]
export const STACK_SIZES = [500, 1000, 1500]
export const STARTING_BLINDS = ['10/20', '15/30']
export const REMATCH_PARAMS_KEY = 'rematch-params'
export const REMATCH_LEADER_KEY = 'rematch-leader'
export const REQUESTED_ZIGS_KEY = 'requested-zigs'
export const DENOMINATION_KEY = 'denomination'
export const POKUR_CHAT = '/apps/escape/groups/~datwet/pokur/channels/chat/~datwet/lobby?channel-inset=true'
