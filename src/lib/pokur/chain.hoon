/-  *pokur, indexer=zig-indexer, wallet=zig-wallet
/+  smart=zig-sys-smart
|%
++  fetch
  |_  [now=@da host-info]
  ++  i-scry
    /(scot %p ship)/uqbar/(scot %da now)/indexer
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
    |=  [src=^ship bond-id=id:smart token-amount=@ud]
    ^-  ?
    ::  find bond information from indexer
    =/  bond=(unit bond:escrow)  (bond-state bond-id)
    ?~  bond  %.n  ::  need bond, reject action
    ::  assert bond info is legit
    ?.  =(address custodian.u.bond)  %.n
    ::  TODO assert timelock is acceptable
    ?~  leader-payment=(~(get by depositors.u.bond) src)  %.n
    ?.  (gte amount.u.leader-payment token-amount)  %.n
    ::  all good!
    %.y
  ::
  ++  valid-new-player
    |=  [src=^ship bond-id=id:smart token-amount=@ud]
    ^-  ?
    ::  find bond information from indexer
    =/  bond=(unit bond:escrow)  (bond-state bond-id)
    ?~  bond  %.n  ::  need bond, reject action
    ?~  player-payment=(~(get by depositors.u.bond) src)  %.n
    ?.  (gte amount.u.player-payment token-amount)  %.n
    ::  all good!
    %.y
  --
--