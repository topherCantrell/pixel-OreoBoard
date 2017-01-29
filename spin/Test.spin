CON
  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000 

OBJ    
    PST  : "Parallax Serial Terminal" 
      
PUB Main | x 
  
  PauseMSec(2_000)

  PST.start(115200)

  PST.str(string("This is a test",13))

  dira := $0F_FF_FF_FF
  outa := %0000_0000_0000_0000__1000__000_0000_00000

  repeat
      PST.str(string("Loop",13))
      PauseMSec(1000)

  'dira := %0000000000000_111_1111_1111_111_11111

'  outa := %0000000000000_111_1111_1111_111_11111
  'outa := %0000000000000_111_1111_1111_111_11111 
  
pri PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)  