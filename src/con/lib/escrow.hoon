/+  *zig-sys-smart
|%
+$  bond
  $:  custodian=address
      timelock=@ud  ::  measured in eth blocks
      =escrow-asset
      depositors=(pmap address [=ship amount=@ud account=id])
  ==
::
+$  escrow-asset
  $:  contract=id
      metadata=id
      amount=@ud
      account=(unit id)
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
      ::  as a custodian, award tokens held in escrow to chosen address
      ::  note that addresses do *not* need to have been depositors
      ::  can award multiple times before timelock is reached
      [%award bond-id=id to=address amount=@ud account=(unit id)]
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