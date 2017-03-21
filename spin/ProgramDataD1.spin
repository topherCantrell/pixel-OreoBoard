pub getProgram
  return @zoeProgram

DAT
zoeProgram

'config
  byte 15
  byte 192
  byte 24
  byte 1

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
  word 0

'pixbuffer ' 1 byte per pixel
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

'events
  byte "INIT",0, $00,$22
  byte "[BLUE]",0, $00,$7A
  byte "[GREEN]",0, $00,$84
  byte "DOIT",0, $00,$8E
  byte $FF

'INIT_handler
  '  var x
  '  configure (out =D1, length=192, hasWhite=false)
  byte $09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 '   defineColor(color=0,W=0, R=0, G=0, B=0)   
  byte $09,$00,$01,$00,$00,$00,$0A,$00,$00,$00,$00 '   defineColor(color=1,W=0, R=0,   G=10, B=0)
  byte $09,$00,$02,$00,$00,$00,$0A,$00,$00,$00,$0A '   defineColor(color=2,W=0, R=0,   G=10, B=10)
  byte $0B,$00,$03,$03,$01,$00,$01,$00,$01,$00,$00,$01,$00 '   pattern(number=0) {
  '	  1.1
  '	  .1.
  '	  .1.
  '  }
  byte $0C,$00,$00,$00,$06,$00,$03,$00,$01 '   drawPattern(number=0,x=6,y=3,colorOffset=1)
  byte $01,$13,$88 '   pause(time=5000)
  byte $04,$00,$00,$00 '   [x] = 0
  'HERE:
  byte $07,$00,$2B '   gosub(doit)
  byte $05,$00,$20,$80,$00,$00,$01 '   [x] = [x] + 1
  byte $06,$00,$04,$03,$80,$00,$00,$C0 '   if([x]>=192)
  byte $04,$00,$00,$00 '     [x] = 0 
  '__gotoFail_0:
  byte $03,$FF,$E7 '   goto(here)
  byte $08 ' }

'[BLUE]_handler
  byte $0A,$00,$02 ' 	solid(color=2)
  'HERE:
  byte $01,$03,$E8 ' 		pause(time=1000)
  byte $03,$FF,$FA ' 		goto(here)
  byte $08 ' }

'[GREEN]_handler
  byte $0A,$00,$01 ' 	solid(color=1)
  'HERE:
  byte $01,$03,$E8 ' 		pause(time=1000)
  byte $03,$FF,$FA ' 		goto(here)
  byte $08 ' }

'DOIT_handler
  byte $0A,$00,$00 ' 	solid(color=0)
  byte $02,$80,$00,$00,$01 ' 	set(pixel=[x],color=1)
  byte $01,$00,$0A ' 	pause(time=10)
  byte $08 ' }

