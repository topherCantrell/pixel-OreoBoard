CON
  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000

CON
 '
    pinD1   = 15 
    pinD2   = 14 
    pinD3   = 13 
    pinD4   = 12 
  
OBJ    
    STRIP    : "NeoPixelStrip"    
    PST      : "Parallax Serial Terminal"

              
pub StripTest 

  ' Go ahead and drive the pixel data lines low.
  dira[pinD1] := 1
  outa[pinD1] := 0

  dira[pinD2] := 1
  outa[pinD2] := 0

  dira[pinD3] := 1
  outa[pinD3] := 0

  dira[pinD4] := 1
  outa[pinD4] := 0

  STRIP.init

  PauseMSec(1000)

  STRIP.draw(2, @colors, @pixels1, pinD1,  8)
  STRIP.draw(2, @colors, @pixels2, pinD2,  8)
  STRIP.draw(2, @colors, @pixels3, pinD3,  8)
  STRIP.draw(2, @colors, @pixels4, pinD4,  8)
     
  repeat
    PauseMSec(5000)       
      
PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)
        
DAT

colors
         '   GG RR BB
    long $00_00_00_00  ' 0
    long $00_00_00_20  ' 1
    long $00_00_20_00  ' 2
    long $00_20_00_00  ' 3
    long $00_20_20_20  ' 4

pixels1
    byte 1,3,2,1,0,1,2,4

pixels2
    byte 2,3,2,1,0,1,2,3

pixels3
    byte 3,3,2,1,0,1,2,3
    
pixels4
    byte 4,3,2,1,0,1,2,3