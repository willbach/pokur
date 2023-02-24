/=  zig  /sur/zig/ziggurat
::
/=  mip  /lib/mip
::
|%
++  make-config
  ^-  config:zig
  ~
::
++  make-virtualships-to-sync
  ^-  (list @p)
  ~[~nec ~bud ~wes]
::
++  make-install
  ^-  ?
  %.y
::
++  make-start-apps
  ^-  (list @tas)
  ~
::
++  make-state-views
  ^-  (list [who=@p app=(unit @tas) file-path=path])
  ::  app=~ -> chain view, not an agent view
  =/  pfix  (cury welp `path`/zig/state-views)
  :~  [~nec ~ (pfix /chain/transactions/hoon)]
      [~nec ~ (pfix /chain/chain/hoon)]
      [~nec ~ (pfix /chain/holder-our/hoon)]
      [~nec ~ (pfix /chain/source-zigs/hoon)]
  ::
      [~nec `%wallet (pfix /agent/wallet-metadata-store/hoon)]
      [~nec `%wallet (pfix /agent/wallet-our-items/hoon)]
      [~wes `%pokur (pfix /agent/pokur-bud-players/hoon)]
  ==
::
++  make-setup
  |^  ^-  (map @p test-steps:zig)
  %-  ~(gas by *(map @p test-steps:zig))
  :^    [~nec make-setup-nec]
      [~bud make-setup-bud]
    [~wes make-setup-wes]
  ~
  ::
  ++  make-setup-nec
    ^-  test-steps:zig
    =/  who=@p  ~nec
    :~  :-  %custom-write
        :^  %send-wallet-transaction  ~
          %-  crip
          %-  noah
          !>  ^-  [@p @p test-write-step:zig]
          :+  who  service-host
          :-  %custom-write
          :^  %deploy-contract  ~
            %-  crip
            "[{<who>} {<service-host>} {<`path`get-escrow-jam-path>} %.n ~]"
          ~
        ~
    ::
        :^  %poke  ~
          :-  who
          :^  who  %pokur-host  %pokur-host-action
          %-  crip
          "[%host-info {<who>} {<(get-address who)>} [(~(got bi:mip configs:test-globals) project:test-globals [{<who>} {<(spat get-escrow-jam-path)>}]) 0x0]]"
        ~
    ::
        (make-find-host who)
    ::
        (make-set-our-address who)
    ==
  ::
  ++  make-setup-bud
    ^-  test-steps:zig
    =/  who=@p  ~bud
    :^    (make-find-host who)
        (make-set-our-address who)
      :-  %custom-write
      :^  %send-wallet-transaction  ~
        %-  crip
        %-  noah
        !>  ^-  [@p @p test-write-step:zig]
        :+  who  service-host
        :^  %poke  ~
          :-  who
          :^  who  %pokur  %pokur-player-action
          %-  crip
          "[%new-table *@da {<service-host>} `[`@ux`'zigs-metadata' 'ZIG' 1.000.000.000.000.000.000 0x0] 2 2 [%sng 1.000 ~m60 ~[[1 2] [2 4] [4 8]] 0 %.n ~[100]] %.y %.y ~m10]"
        ~
      ~
    ~
  ::
  ++  make-setup-wes
    ^-  test-steps:zig
    =/  who=@p  ~wes
    ~[(make-find-host who) (make-set-our-address who)]
  ::
  ++  make-set-our-address
    |=  who=@p
    ^-  test-step:zig
    :^  %poke  ~
      :-  who
      :^  who  %pokur  %pokur-player-action
      (crip "[%set-our-address {<(get-address who)>}]")
    ~
  ++  make-find-host
    |=  who=@p
    ^-  test-step:zig
    :^  %poke  ~
      :-  who
      :^  who  %pokur  %pokur-player-action
      %-  crip
      "[%find-host {<service-host>}]"
    ~
  --
::
++  get-address
  |=  who=@p
  ^-  @ux
  %.  ['global' [who %address]]
  ~(got bi:mip configs:test-globals)
::
++  service-host
  ^-  @p
  ~nec
::
++  get-escrow-jam-path
  ^-  path
  /con/compiled/escrow/jam
--
