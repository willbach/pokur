::
::  token escrow contract for managing pokur games
::  (but general enough to be used for anything?)
::
/+  *zig-sys-smart
/=  lib  /con/lib/escrow
|_  =context
++  write
  |=  act=action:lib
  ^-  (quip call diff)
  ?-    -.act
      %new-bond
    ::  get token metadata
    =/  meta  (need (scry-state asset-metadata.act))
    ?>  ?=(%& -.meta)
    =/  our-account=(unit id)
      =-  ?~((scry-state i) ~ `i)
      i=(hash-data source.p.meta this.context town.context salt.p.meta)
    =/  bond-salt
      (cat 3 id.caller.context nonce.caller.context)
    =-  `(result ~ [- ~] ~ ~)
    :*  %&
        (hash-data this.context this.context town.context bond-salt)
        this.context
        this.context
        town.context
        bond-salt
        %bond
        :^    id.caller.context
            timelock.act
          [source.p.meta asset-metadata.act 0 our-account]
        ~
    ==
  ::
      %deposit
    =/  bond
      =+  (need (scry-state bond-id.act))
      (husk bond:lib - `this.context `this.context)
    ::  adjust asset, add caller as depositor
    =.  amount.escrow-asset.noun.bond
      (add amount.escrow-asset.noun.bond amount.act)
    ::  assert caller is not yet a depositor
    ?<  (~(has py depositors.noun.bond) id.caller.context)
    =.  depositors.noun.bond
      %+  ~(put py depositors.noun.bond)
        id.caller.context
      [amount.act account.act]
    ::  return result bond + make %take call to token
    :_  (result [%&^bond ~] ~ ~ ~)
    :~  :+  contract.escrow-asset.noun.bond
          town.context
        :*  %take
            this.context
            amount.act
            account.act
            account.escrow-asset.noun.bond
        ==
    ==
  ::
      %award
    =/  bond
      =+  (need (scry-state bond-id.act))
      (husk bond:lib - `this.context `this.context)
    ::  assert awarded tokens add up to total amount in escrow
    ?>  .=  amount.escrow-asset.noun.bond
        =+  total=0
        |-
        ?~  to.act  total
        $(to.act t.to.act, total (add total amount.i.to.act))
    ::  zero out and destroy the bond item
    =:  amount.escrow-asset.noun.bond  0
        depositors.noun.bond           ~
    ==
    :_  (result ~ ~ [%&^bond ~] ~)
    %+  turn  to.act
    |=  [=address amount=@ud account=(unit id)]
    ^-  call
    :+  contract.escrow-asset.noun.bond
      town.context
    :*  %give
        address
        amount
        (need account.escrow-asset.noun.bond)
        account
    ==
  ::
      %release
    =/  bond
      =+  (need (scry-state bond-id.act))
      (husk bond:lib - `this.context `this.context)
    ::  timelock must have passed
    ?>  (gth eth-block.context timelock.noun.bond)
    ::  tokens must remain in contract
    ?>  (gth amount.escrow-asset.noun.bond 0)
    ::  all tokens returned to depositors
    ::  zero out and destroy the bond item
    =:  amount.escrow-asset.noun.bond  0
        depositors.noun.bond           ~
    ==
    :_  (result ~ ~ [%&^bond ~] ~)
    %+  turn  ~(tap py depositors.noun.bond)
    |=  [=address amount=@ud account=id]
    ^-  call
    :+  contract.escrow-asset.noun.bond
      town.context
    :*  %give
        address
        amount
        (need account.escrow-asset.noun.bond)
        `account
    ==
  ::
  ==
++  read
  |_  =path
  ++  json
    ~
  ++  noun
    ~
  --
--
