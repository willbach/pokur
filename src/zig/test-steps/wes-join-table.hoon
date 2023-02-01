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
    :+  %scry
      :-  who
      :^  'update:pokur'  %gx  %pokur
      /lobby/noun/noun
    ''
  ::
    :^  %custom-write  %send-wallet-transaction
      %-  crip
      %-  noah
      !>  ^-  [@p @p test-write-step:zig]
      :+  who  service-host
      :+  %poke
        :-  who
        :^  who  %pokur  %pokur-player-action
        %-  crip
        """
        ::  +snag 1 rather than 0 because a pending-store
        ::   scry happens in %send-wallet-transaction
        ::   custom-step between the %pokur scry above
        ::   and the %pokur %poke here:
        =/  lobby-result=test-result:zig
          (snag 1 test-results:test-globals)
        ?>  ?=([* ~] lobby-result)
        =/  lobby-update=update:pokur
          !<(update:pokur result:i:lobby-result)
        ?>  ?=(%lobby -.lobby-update)
        =/  table-ids=(list @da)
          ~(tap in ~(key by tables.lobby-update))
        ?>  ?=([@ ~] table-ids)
        =*  table-id  i.table-ids
        [%join-table id=table-id buy-in=1.000.000.000.000.000.000 public=%.y]
        """
      ~
    ~
  ::
    :+  %scry
      :-  who
      :^  '[@t boat:gall bitt:gall]'  %gx  %subscriber
      /agent-state/pokur/''/noun/noun
    ''
  ==
--
