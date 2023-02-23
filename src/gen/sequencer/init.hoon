/-  *zig-sequencer
/+  ethereum, merk, smart=zig-sys-smart
/=  zigs-mar      /con/mar/zigs
/=  escrow-mar    /con/mar/escrow
/*  zigs-contract      %jam  /con/compiled/zigs/jam
/*  escrow-contract    %jam  /con/compiled/escrow/jam
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [rollup-host=@p town-id=@ux private-key=@ux ~] ~]
::  one hundred million testnet zigs, now and forever
=/  testnet-zigs-supply  100.000.000.000.000.000.000.000.000
::
=/  pubkey-1  0x7a9a.97e0.ca10.8e1e.273f.0000.8dca.2b04.fc15.9f70
=/  pubkey-2  0xd6dc.c8ff.7ec5.4416.6d4e.b701.d1a6.8e97.b464.76de
=/  pubkey-3  0x5da4.4219.e382.ad70.db07.0a82.12d2.0559.cf8c.b44d
=/  zigs-1  (hash-data:smart zigs-contract-id:smart pubkey-1 town-id `@`'zigs')
=/  zigs-2  (hash-data:smart zigs-contract-id:smart pubkey-2 town-id `@`'zigs')
=/  zigs-3  (hash-data:smart zigs-contract-id:smart pubkey-3 town-id `@`'zigs')
::
=/  beef-zigs-item
  ^-  item:smart
  :*  %&
      zigs-1
      zigs-contract-id:smart
      pubkey-1
      town-id
      `@`'zigs'
      %account
      [300.000.000.000.000.000.000 ~ `@ux`'zigs-metadata' 0]
  ==
=/  dead-zigs-item
  ^-  item:smart
  :*  %&
      zigs-2
      zigs-contract-id:smart
      pubkey-2
      town-id
      `@`'zigs'
      %account
      [200.000.000.000.000.000.000 ~ `@ux`'zigs-metadata' 0]
  ==
=/  cafe-zigs-item
  ^-  item:smart
  :*  %&
      zigs-3
      zigs-contract-id:smart
      pubkey-3
      town-id
      `@`'zigs'
      %account
      [100.000.000.000.000.000.000 ~ `@ux`'zigs-metadata' 0]
  ==
::
=/  zigs-metadata
  ^-  data:smart
  :*  `@ux`'zigs-metadata'
      zigs-contract-id:smart
      zigs-contract-id:smart
      town-id
      `@`'zigs'
      %token-metadata
      :*  name='UQ| Tokens'
          symbol='ZIG'
          decimals=18
          supply=testnet-zigs-supply
          cap=~
          mintable=%.n
          minters=~
          deployer=0x0
          salt=`@`'zigs'
      ==
  ==
::  zigs.hoon contract
=/  zigs-pact
  ^-  pact:smart
  :*  zigs-contract-id:smart  ::  id
      zigs-contract-id:smart  ::  source
      zigs-contract-id:smart  ::  holder
      town-id                ::  town-id
      [- +]:(cue zigs-contract)
      interface=`pith:smart`[%ux `@ux`(sham zigs-mar)]^~
  ==
::  escrow.hoon contract
=/  escrow-pact
  ^-  pact:smart
  :*  0xabcd.abcd  ::  id
      0x0          ::  source
      0x0          ::  holder
      town-id      ::  town-id
      [- +]:(cue escrow-contract)
      interface=`pith:smart`[%ux `@ux`(sham escrow-mar)]^~
  ==
::
=/  fake-state
  ^-  state
  %+  gas:(bi:merk id:smart item:smart)
    *(merk:merk id:smart item:smart)
  :~  [id.zigs-pact [%| zigs-pact]]
      [id.escrow-pact [%| escrow-pact]]
      [zigs-1 beef-zigs-item]
      [zigs-2 dead-zigs-item]
      [zigs-3 cafe-zigs-item]
      [id.zigs-metadata [%& zigs-metadata]]
  ==
::
:-  %sequencer-town-action
^-  town-action
:*  %init
    rollup-host
    (address-from-prv:key:ethereum private-key)
    private-key
    town-id
    `[fake-state ~]
    [%full-publish ~]
==
