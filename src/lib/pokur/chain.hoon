/-  *pokur, indexer=zig-indexer, wallet=zig-wallet
/+  smart=zig-sys-smart
|%
++  fetch
  |_  [[our=@p now=@da] host-info]
  ++  i-scry
    /(scot %p our)/uqbar/(scot %da now)/indexer
  ++  bond-state
    |=  bond-id=id:smart
    ^-  (unit bond:escrow)
    ~&  >>  "%pokur-host: fetching bond {<bond-id>}"
    ::  scry the indexer
    =/  =update:indexer
      .^  update:indexer  %gx
          %+  weld  i-scry
          /newest/item/(scot %ux town.contract)/(scot %ux bond-id)/noun
      ==
    ?@  update  ~
    ::  parse single bond
    ?.  ?=(%newest-item -.update)  ~
    ?>  ?=(%& -.item.update)
    ((soft bond:escrow) noun.p.item.update)
  ::
  ++  total-payout
    |=  bond-id=id:smart
    ^-  @ud
    =/  =bond:escrow  (need (bond-state bond-id))
    amount.escrow-asset.bond
  ::
  ++  valid-new-table
    |=  [src=^ship on-batch=? bond-id=id:smart token-amount=@ud]
    ^-  (unit ?)
    ::  find bond information from indexer
    =/  bond=(unit bond:escrow)  (bond-state bond-id)
    ::  make sure our address has been set
    ?:  =(0x0 address)  `%.n
    ?~  bond
      ::  need bond, can't find it in our chain state
      ::  if not on-batch, kick over to pending
      ?.(on-batch ~ `%.n)
    ::  we have bond in our local chain state
    ::  assert bond info is legit
    ?.  =(address custodian.u.bond)  `%.n
    ::  TODO assert timelock is acceptable
    ?~  leader-payment=(~(get by depositors.u.bond) src)  `%.n
    ?.  (gte amount.u.leader-payment token-amount)  `%.n
    ::  all good!
    `%.y
  ::
  ++  valid-new-player
    |=  [src=^ship on-batch=? bond-id=id:smart token-amount=@ud]
    ^-  (unit ?)
    ::  find bond information from indexer
    =/  bond=(unit bond:escrow)  (bond-state bond-id)
    ?~  bond  `%.n  ::  need bond, reject action
    ?~  player-payment=(~(get by depositors.u.bond) src)
      ::  not seeing payment yet
      ::  if not on-batch, kick over to pending
      ?.(on-batch ~ `%.n)
    ?.  (gte amount.u.player-payment token-amount)  `%.n
    ::  all good!
    `%.y
  --
--