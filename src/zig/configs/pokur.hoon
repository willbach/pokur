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
    :^    :^  %custom-write  %send-wallet-transaction
            %-  crip
            %-  noah
            !>  ^-  [@p @p test-write-step:zig]
            :+  who  service-host
            :+  %poke
              :-  who
              :^  who  %uqbar  %wallet-poke
              %-  crip
              "[%transaction ~ from={<(get-address service-host)>} {<publish-contract-hash>} {<town-id>} action=[%noun [%deploy mutable=%.n cont={<get-escrow-contract>} interface=~ types=~]]]"
            ~
          ~
        :+  %poke
          :-  who
          :^  who  %pokur-host  %pokur-host-action
          %-  crip
          "[%host-info {<who>} {<(get-address who)>} [{<compute-escrow-contract-hash>} 0x0]]"
        ~
      (make-set-our-address who)
    ~
  ::
  ++  make-setup-bud
    ^-  test-steps:zig
    =/  who=@p  ~bud
    :+  (make-set-our-address who)
      :^  %custom-write  %send-wallet-transaction
        %-  crip
        %-  noah
        !>  ^-  [@p @p test-write-step:zig]
        :+  who  service-host
        :+  %poke
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
    ~[(make-set-our-address who)]
  ::
  ++  make-set-our-address
    |=  who=@p
    ^-  test-step:zig
    :+  %poke
      :-  who
      :^  who  %pokur  %pokur-player-action
      (crip "[%set-our-address {<(get-address who)>}]")
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
++  town-id
  ^-  @ux
  0x0
::
++  publish-contract-hash
  ^-  @ux
  0x1111.1111
::
++  get-escrow-contract
  |^
  =/  escrow-jam-path=path
    %+  weld  /(scot %p our:test-globals)/pokur
    /(scot %da now:test-globals)/con/compiled/escrow/jam
  (get-contract escrow-jam-path)
  ::
  ++  get-contract
    |=  contract-jam-path=path
    [- +]:(cue .^(@ %cx contract-jam-path))
  --
::
++  compute-contract-hash
  hash-pact:smart:zig
::
++  compute-escrow-contract-hash
  %-  compute-contract-hash
  :^  0x0  (get-address service-host)  town-id  ::  substitute publish-contract-hash with 0x0 if mutable=%.y
  get-escrow-contract
--
