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
    ~&  update
    ?@  update  ~
    ::  parse single bond
    ?.  ?=(%newest-item -.update)  ~
    ?>  ?=(%& -.item.update)
    ((soft bond:escrow) noun.p.item.update)
  ::
  ++  valid-new-table
    |=  [bond-id=id:smart src=^ship]
    ^-  ?
    ::  find bond information from indexer
    =/  bond=(unit bond:escrow)  (bond-state bond-id)
    ?~  bond  %.n  ::  need bond, reject action
    ::  assert bond info is legit
    ?.  =(address custodian.u.bond)  %.n
    ::  TODO assert timelock is acceptable
    =/  leader-payment=[=^ship addr=@ux amt=@ud acct=@ux]
      -:~(tap by depositors.u.bond)
    ?.  =(ship.leader-payment src)  %.n
    ?.  =(amt.leader-payment amount.escrow-asset.u.bond)  %.n
    ::  all good!
    %.y
  ::
  ++  valid-new-player
    |=  [bond-id=id:smart src=^ship]
    ^-  ?
    ::  find bond information from indexer
    =/  bond=(unit bond:escrow)  (bond-state bond-id)
    ?~  bond  %.n  ::  need bond, reject action
    =/  player-payment=[=^ship addr=@ux amt=@ud acct=@ux]
      -:~(tap by depositors.u.bond)
    ?.  =(ship.player-payment src)  %.n
    ?.  =(amt.player-payment amount.escrow-asset.u.bond)  %.n
    ::  all good!
    %.y
  --
--