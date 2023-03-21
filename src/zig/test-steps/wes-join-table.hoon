/=  indexer  /sur/zig/indexer
/=  pokur    /sur/pokur
/=  zig      /sur/zig/ziggurat
::
/=  mip      /lib/mip
::
|%
++  who
  ^-  @p
  ~wes
::
++  service-host
  ^-  @p
  ~nec
::
++  $
  ^-  test-steps:zig
  :~
    :^  %scry  `%lobby-update
      :-  who
      :^  'update:pokur'  %gx  %pokur
      '/lobby/noun/noun'
    ''
  ::
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
        """
        ?>  ?=(%lobby -.lobby-update)
        =/  table-ids=(list @da)
          ~(tap in ~(key by tables.lobby-update))
        ?>  ?=([@ ~] table-ids)
        =*  table-id  i.table-ids
        [%join-table id=table-id buy-in=1.000.000.000.000.000.000 public=%.y]
        """
      ~
    ~
  ==
--
