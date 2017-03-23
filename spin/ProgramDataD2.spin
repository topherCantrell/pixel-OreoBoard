pub getProgram
  return @zoeProgram

DAT
zoeProgram

'config
  byte 14
  byte 66
  byte 24
  byte 0

'eventInput
  byte 1, "INIT",0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0

'palette  ' 64 longs (64 colors)
  long 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  long 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  long 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  long 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

'patterns ' 16 pointers
  word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

'callstack ' 32 pointers
  word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

'variables ' Variable storage (2 bytes each)

'pixbuffer ' 1 byte per pixel
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  byte 0,0

'events
  byte "INIT",0, $00,$08
  byte $FF

'INIT_handler
  '	configure (out=D2, length=66, hasWhite=false)
  byte $09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ' 	defineColor(color=0,   W=0, R=0,   G=0,   B=0)    // Color 0  : Black   
  byte $09,$00,$01,$00,$00,$00,$00,$00,$64,$00,$00 '     defineColor(color=1,   W=0, R=100, G=0,   B=0)    // Color 1  : Red
  byte $09,$00,$02,$00,$00,$00,$64,$00,$00,$00,$00 '     defineColor(color=2,   W=0, R=0, G=100,   B=0)    // Color 2  : Green
  byte $09,$00,$03,$00,$00,$00,$00,$00,$00,$00,$64 '     defineColor(color=3,   W=0, R=0, G=0,   B=100)    // Color 1  : Blue
  byte $0A,$00,$01 '     solid(color=1)
  'HERE:
  byte $01,$03,$E8 ' 	pause(time=1000)
  byte $03,$FF,$FA ' 	goto(here) 
  byte $08 ' }

