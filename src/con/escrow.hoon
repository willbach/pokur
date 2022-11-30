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
    =-  `(result ~ [%&^- ~] ~ [[%new-bond s+(scot %ux id.-)]]^~)
    :*  id=(hash-data this.context this.context town.context bond-salt)
        this.context
        this.context
        town.context
        bond-salt
        %bond
        :^    custodian.act
            timelock.act
          [source.p.meta asset-metadata.act 0 our-account]
        ~
    ==
  ::
      %new-bond-with-deposit
    ::  get token metadata
    =/  meta  (need (scry-state asset-metadata.act))
    ?>  ?=(%& -.meta)
    =/  i=id
      (hash-data source.p.meta this.context town.context salt.p.meta)
    =/  our-account=(unit id)
      ?~((scry-state i) ~ `i)
    =/  bond-salt
      (cat 3 id.caller.context nonce.caller.context)
    :-  :_  ~
        :+  source.p.meta
          town.context
        :*  %take
            this.context
            amount.act
            account.act
            our-account
        ==
    =-  (result ~ [- ~] ~ `(list event)`[%new-bond s+(scot %ux -.+.-)]^~)
    :*  %&
        (hash-data this.context this.context town.context bond-salt)
        this.context
        this.context
        town.context
        bond-salt
        %bond
        :^    custodian.act
            timelock.act
          [source.p.meta asset-metadata.act amount.act i]
        (make-pmap ~[[ship.act id.caller.context amount.act account.act]])
    ==
  ::
      %deposit
    =/  bond
      =+  (need (scry-state bond-id.act))
      (husk bond:lib - `this.context `this.context)
    ::  adjust asset, add caller as depositor
    =.  amount.escrow-asset.noun.bond
      (add amount.escrow-asset.noun.bond amount.act)
    =.  depositors.noun.bond
      ?:  (~(has py depositors.noun.bond) ship.act)
        ::  if already a depositor, add amount to previous
        %+  ~(jab py depositors.noun.bond)
          ship.act
        |=  [=address amount=@ud account=id]
        ?>  =(address id.caller.context)
        [address (add amount amount.act) account]
      ::  otherwise add new depositor
      %+  ~(put py depositors.noun.bond)
        ship.act
      [id.caller.context amount.act account.act]
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
    ::  give asset
    :-  :_  ~
        :+  contract.escrow-asset.noun.bond
          town.context
        :*  %give
            to.act
            amount.act
            (need account.escrow-asset.noun.bond)
            account.act
        ==
    ::  if award adds up to total amount in escrow, destroy bond here
    ?:  =(amount.escrow-asset.noun.bond amount.act)
      ::  zero out and destroy the bond item
      =:  amount.escrow-asset.noun.bond  0
          depositors.noun.bond           ~
      ==
      (result ~ ~ [%&^bond ~] ~)
    ::  if award is partial, bond is modified and not destroyed
    =:  amount.escrow-asset.noun.bond
      (sub amount.escrow-asset.noun.bond amount.act)
    ::  if awarded to a depositor, subtract their claim
        depositors.noun.bond
      %-  ~(urn py depositors.noun.bond)
      |=  [=ship =address amount=@ud account=id]
      ?:  =(address to.act)
        [address (sub amount amount.act) account]
      [address amount account]
    ==
    (result [%&^bond ~] ~ ~ ~)
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
    |=  [=ship =address amount=@ud account=id]
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
