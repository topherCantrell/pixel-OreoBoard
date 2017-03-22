pub getProgram
  return @zoeProgram

DAT
zoeProgram

'config
  byte 15
  byte 192
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
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

'events
  byte "INIT",0, $00,$2A
  byte "ALTERNATE",0, $01,$06
  byte "JIGGLE",0, $01,$07
  byte "SHRINKGROW",0, $01,$08
  byte $FF

'INIT_handler
  '  configure (out=D1, length=192, hasWhite=false)
  byte $09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 '   defineColor(color=0,   W=0, R=0,   G=0,   B=0)    // Color 0  : Black   
  byte $09,$00,$01,$00,$00,$00,$00,$00,$64,$00,$00 '   defineColor(color=1,   W=0, R=100, G=0,   B=0)    // Color 1  : Red
  byte $09,$00,$02,$00,$00,$00,$64,$00,$96,$00,$0A '   defineColor(color=2,   W=0, R=150, G=100, B=10)   // Color 2  : Yellow(ish)
  byte $09,$00,$08,$00,$00,$00,$00,$00,$00,$00,$64 '   defineColor(color=8,   W=0, R=0,   G=0,   B=100)  // Color 8  : Blue   
  byte $09,$00,$09,$00,$00,$00,$32,$00,$32,$00,$32 '   defineColor(color=9,   W=0, R=50,  G=50,  B=50)   // Color 9  : White
  byte $09,$00,$0A,$00,$00,$00,$32,$00,$32,$00,$32 '   defineColor(color=10,  W=0, R=50,  G=50,  B=50)   // Color 10 : White
  byte $09,$00,$0B,$00,$00,$00,$00,$00,$64,$00,$00 '   defineColor(color=11,  W=0, R=100, G=0,   B=0)    // Color 16 : Red   
  byte $09,$00,$0C,$00,$00,$00,$32,$00,$32,$00,$32 '   defineColor(color=12,  W=0, R=50,  G=50,  B=50)   // Color 17 : White
  byte $09,$00,$0D,$00,$00,$00,$32,$00,$32,$00,$32 '   defineColor(color=13,  W=0, R=50,  G=50,  B=50)   // Color 18 : White
  byte $0B,$00,$05,$07,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01 '   pattern(number=0) {
  '	  11111
  '	  1....
  '	  1....
  '	  .111.
  '	  ....1
  '	  ....1
  '	  11111
  '  }
  byte $0B,$01,$05,$07,$02,$02,$02,$02,$02,$02,$00,$00,$00,$02,$02,$00,$00,$00,$02,$00,$02,$02,$02,$00,$02,$00,$00,$00,$02,$02,$00,$00,$00,$02,$02,$02,$02,$02,$02 '   pattern(number=1){
  '      22222
  '      2...2
  '      2...2
  '      .222.
  '      2...2
  '      2...2
  '      22222
  '  }  
  byte $0C,$00,$00,$00,$00,$00,$00,$00,$00 '   drawPattern(number=0,  x=0,  y=0)
  byte $0C,$00,$01,$00,$06,$00,$00,$00,$00 '   drawPattern(number=1,  x=6,  y=0)
  byte $0C,$00,$00,$00,$0C,$00,$00,$00,$00 '   drawPattern(number=0,  x=12, y=0)
  byte $0C,$00,$01,$00,$12,$00,$00,$00,$00 '   drawPattern(number=1,  x=18, y=0)
  byte $01,$13,$88 '   pause(time=5000)
  'HERE:
  byte $03,$FF,$FD '   goto(here)
  byte $08 ' }

'ALTERNATE_handler
  byte $08 ' }

'JIGGLE_handler
  byte $08 ' }

'SHRINKGROW_handler
  byte $08 ' }

