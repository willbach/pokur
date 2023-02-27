/-  spider
/+  strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
|^
=/  url
  "https://api.etherscan.io/api?module=proxy&action=eth_blockNumber"
;<  =json  bind:m
  (fetch-json:strandio url)
(pure:m !>(`@ud`(scan `tape`(slag 2 (pars json)) hex)))
::
+$  api-key  cord
++  pars
  =,  dejs:format
  %-  ot
  :~  [%result sa]
  ==
--