/+  *zig-sys-smart
/=  esc  /con/lib/escrow
|_  [label=@tas n=noun]
++  data
  |%
  ++  noun
    ?+  label  !!
      %bond   ;;(bond:esc n)
    ==
  ++  json
    ^-  ^json
    ?+    label  !!
        %bond
      =+  ;;(bond:esc n)
      %-  pairs:enjs:format
      :~  ['custodian' s+(scot %ud balance.-)]
          ['timelock' s+(scot %ud timelock.-)]
          ::
          :-  'escrow-asset'
          %-  pairs:enjs:format
          :~  ['contract' s+(scot %ux contract.escrow-asset.-)]
              ['metadata' s+(scot %ux metadata.escrow-asset.-)]
              ['amount' s+(scot %ud amount.escrow-asset.-)]
              ['account' s+(scot %ux account.escrow-asset.-)]
          ==
          ::
          :-  'depositors'
          %-  pairs:enjs:format
          %+  turn  ~(tap py depositors.-)
          |=  [=ship =address amt=@ud]
          :-  (scot %p ship)
          %-  pairs:enjs:format
          :~  ['address' s+(scot %ux address)]
              ['amount' s+(scot %ud amt)]
          ==
      ==
    ==
  --
::
++  action
  |%
  ++  noun
    ;;(action:esc [label n])
  ++  json
    =/  act  ;;(action:esc [label n])
    !!  ::  TODO
  --
::  TODO
::  ++  event
::    |%
::    ++  noun  !!
::    ++  json  !!
::    --
--