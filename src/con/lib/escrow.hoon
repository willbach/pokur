/+  *zig-sys-smart
|%
+$  bond
  $:  custodian=address
      timelock=@ud  ::  measured in eth blocks
      =escrow-asset
      depositors=(pmap ship [=address amount=@ud])
  ==
::
+$  escrow-asset
  $:  contract=id
      metadata=id
      amount=@ud
      account=id
  ==
::
+$  action
  $%  ::  create a new bond held by this contract.
      ::  sets escrow asset but not amount or depositors
      [%new-bond custodian=address timelock=@ud asset-metadata=id]
      ::  become a depositor in a bond -- caller must first
      ::  set appropriate allowance for this contract
      ::  can deposit multiple times
      [%deposit bond-id=id =ship amount=@ud account=id]
      ::  combo of above two used for %pokur
      $:  %new-bond-with-deposit
          custodian=address  timelock=@ud  asset-metadata=id
          =ship  amount=@ud  account=id
      ==
      ::  as a custodian, award tokens held in escrow
      ::  note that ships need to have been depositors
      ::  can award multiple times before timelock is reached
      [%award bond-id=id to=ship amount=@ud]
      ::  as a custodian, nullify the bond before its timelock
      [%refund bond-id=id]
      ::  anyone can submit -- returns all funds to depositors
      ::  if the bond's timelock has passed and not all tokens
      ::  have been awarded.
      [%release bond-id=id]
  ==
::
::  standard fungible token metadata
::
+$  token-metadata
  $:  name=@t
      symbol=@t
      decimals=@ud
      supply=@ud
      cap=(unit @ud)
      mintable=?
      minters=(pset address)
      deployer=address
      salt=@
  ==
--