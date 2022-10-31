/+  *zig-sys-smart
|%
+$  bond
  $:  custodian=address
      timelock=@ud  ::  measured in eth blocks
      =escrow-asset
      depositors=(pmap address [amount=@ud account=id])
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
  $%  ::  caller becomes custodian of a new item held by this contract.
      ::  sets escrow asset but not amount or depositors
      [%new-bond timelock=@ud asset-metadata=id]
      ::  become a depositor in a bond -- caller must first
      ::  set appropriate allowance for this contract
      [%deposit bond-id=id amount=@ud account=id]
      ::  as a custodian, award tokens held in escrow to chosen address
      ::  total amount awarded *must* add up to amount of tokens held
      ::  note that addresses do *not* need to have been depositors
      [%award bond-id=id to=(list [=address amount=@ud account=(unit id)])]
      ::  anyone can submit -- returns all funds to depositors
      ::  if the bond's timelock has passed and tokens have not
      ::  been awarded.
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