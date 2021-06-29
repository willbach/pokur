/-  poker :: import types from sur/poker.hoon
=,  poker
|%
++  atom-to-card-val
  |=  n=@ud
  ^-  card-val
  ?+  n  !! :: ^-(card-val `@tas`n) :: if non-face card just use number?? need to coerce type
    %1   %ace
    %2   %2
    %3   %3
    %4   %4
    %5   %5
    %6   %6
    %7   %7
    %8   %8
    %9   %9
    %10  %10
    %11  %jack
    %12  %queen
    %13  %king
  ==
++  atom-to-suit
  |=  val=@ud
  ^-  suit
  ?+  val  !!
    %1  %hearts
    %2  %spades
    %3  %clubs
    %4  %diamonds
  ==
++  generate-deck
  ^-  poker-deck
  =|  new-deck=poker-deck
  =/  i  1
  |-
  ?:  (gth i 4)
    new-deck
  =/  j  1
  |-
  ?.  (lte j 13)
    ^$(i +(i))
  %=  $
    j         +(j)
    new-deck  [(atom-to-card-val j) (atom-to-suit i)]^new-deck
  ==
++  shuffle-deck
  |=  [unshuffled=poker-deck entropy=@]
  ^-  poker-deck
  =|  shuffled=poker-deck
  =/  random  ~(. og entropy)
  =/  remaining  (lent unshuffled)
  |-
  ?:  =(remaining 1)
    :_  shuffled
    (snag 0 unshuffled)
  =^  index  random  (rads:random remaining)
  %=  $
    shuffled      (snag index unshuffled)^shuffled
    remaining     (dec remaining)
    unshuffled    (oust [index 1] unshuffled)
  ==
++  draw
  |=  [n=@ud d=poker-deck]
  ^-  [hand=poker-deck rest=poker-deck]
  :-  (scag n d)
  (slag n d)
--