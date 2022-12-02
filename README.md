# pokur
Urbit Texas Hold'em app

**under construction**

**real monies game:**

**make sure to pull latest from `uqbar-core/dr/wallet-api-upgrades`.**

Copy `con/compiled/escrow.jam` from here into that location in the `uqbar-core` repo.

Copy `gen/sequencer/init.hoon` from here into `uqbar-core`, replacing the file at that location.

Install the %zig desk on both ships.

Run the normal startup commands in `uqbar-core` README to set up **~zod** as the rollup host and sequencer:
```hoon
:rollup|activate
:indexer &set-sequencer [our %sequencer]
:indexer &set-rollup [our %rollup]
:sequencer|init our 0x0 0xc9f8.722e.78ae.2e83.0dd9.e8b9.db20.f36a.1bc4.c704.4758.6825.c463.1ab6.daee.e608
:uqbar &wallet-poke [%import-seed 'uphold apology rubber cash parade wonder shuffle blast delay differ help priority bleak ugly fragile flip surge shield shed mistake matrix hold foam shove' 'squid' 'nickname']
```

Many of these instructions can be better done through the wallet frontend.

Run the following commands on **~bus**:
```hoon
:indexer &set-sequencer [~zod %sequencer]
:indexer &set-rollup [~zod %rollup]
:uqbar &wallet-poke [%import-seed 'post fitness extend exit crack question answer fruit donkey quality emotion draw section width emotion leg settle bulb zero learn solution dutch target kidney' 'squid' 'nickname']
```

Now, we can start a moneyed game.
We'll use zigs tokens for a sit n go.

On **~zod**:
First set your allowance so the escrow contract can take up to 1 million zigs from you:
```hoon
:uqbar &wallet-poke [%transaction ~ from=0x7a9a.97e0.ca10.8e1e.273f.0000.8dca.2b04.fc15.9f70 contract=0x74.6361.7274.6e6f.632d.7367.697a town=0x0 action=[%noun [%set-allowance who=0xabcd.abcd amount=1.000.000 account=0x89a0.89d8.dddf.d13a.418c.0d93.d4b4.e7c7.637a.d56c.96c0.7f91.3a14.8174.c7a7.71e6]]]
:uqbar &wallet-poke [%submit from=0x7a9a.97e0.ca10.8e1e.273f.0000.8dca.2b04.fc15.9f70 hash=[yourhash] gas=[rate=1 bud=1.000.000]]
```
Then set wallet to automatically process transactions from **%pokur-host**. This is so ~zod can manage games automatically, including payouts at the end. We're setting a gas budget here for those automatic transactions as well.
```hoon
:wallet &wallet-poke [%approve-origin [%pokur-host /awards] [1 1.000.000]]
```

Then make a table. This is a sit'n'go table that awards 100% of winnings to 1st place:
```hoon
:pokur &pokur-player-action [%set-our-address 0x7a9a.97e0.ca10.8e1e.273f.0000.8dca.2b04.fc15.9f70]
:pokur &pokur-player-action [%new-table *@da ~zod `[`@ux`'zigs-metadata' 1.000 0x0] 2 2 [%sng 1.000 ~m60 ~[[1 2] [2 4] [4 8]] 0 %.n ~[100]] %.y %.y ~m10]
```
Fill in tx hash, submit and sequence:
```hoon
:uqbar &wallet-poke [%submit from=0x7a9a.97e0.ca10.8e1e.273f.0000.8dca.2b04.fc15.9f70 hash=[yourhash] gas=[rate=1 bud=1.000.000]]
:sequencer|batch
```

Now the table will be created and available from host. ~bus should see the update -- now we can join with **~bus**.

First set approval to spend zigs
```hoon
:uqbar &wallet-poke [%transaction ~ from=0xd6dc.c8ff.7ec5.4416.6d4e.b701.d1a6.8e97.b464.76de contract=0x74.6361.7274.6e6f.632d.7367.697a town=0x0 action=[%noun [%set-allowance who=0xabcd.abcd amount=1.000.000 account=0xd79b.98fc.7d3b.d71b.4ac9.9135.ffba.cc6c.6c98.9d3b.8aca.92f8.b07e.a0a5.3d8f.a26c]]]
:uqbar &wallet-poke [%submit from=0xd6dc.c8ff.7ec5.4416.6d4e.b701.d1a6.8e97.b464.76de hash=[yourhash] gas=[rate=1 bud=1.000.000]]
```

Then make the join transaction:
```hoon
:pokur &pokur-player-action [%set-our-address 0xd6dc.c8ff.7ec5.4416.6d4e.b701.d1a6.8e97.b464.76de]
:pokur &pokur-player-action [%join-table <table-id>]
:uqbar &wallet-poke [%submit from=0xd6dc.c8ff.7ec5.4416.6d4e.b701.d1a6.8e97.b464.76de hash=[yourhash] gas=[rate=1 bud=1.000.000]]
```

Then, run a batch on **~zod** so these txns go through:
```hoon
:sequencer|batch
```

You can now start the game on **~zod**. At the end, the winning ship should be awarded 2.000 zigs!
```hoon
:pokur &pokur-player-action [%start-game <table-id>]
```

----------------------

**fake monies game:**

On ship ~zod:
```
:pokur &pokur-player-action [%new-table *@da ~zod ~ 2 2 [%sng 1.000 ~m60 ~[[1 2] [2 4] [4 8]] 0 %.n ~[100]] %.y %.y ~m10]
```

(look at "lobbies available" print to find table id -- this prints twice, is ok)

On ship ~bus:
```
:pokur &pokur-player-action [%join-table <id>]
```

On ~zod:
```
:pokur &pokur-player-action [%start-game <id>]
```

On ~bus:
```
:pokur|bet 1  ::  call big blind
```

can play game from here using format `:pokur|[bet/check/fold]` where only bet takes any further input

