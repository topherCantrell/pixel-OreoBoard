pub getProgram
  return @zoeProgram

DAT
zoeProgram

'config
  byte 12
  byte 92
  byte 24
  byte 3

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
  word 0,0,0

'pixbuffer ' 1 byte per pixel
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

'events
  byte "INIT",0, $00,$3E
  byte "[MODETELEOP]",0, $00,$5E
  byte "[GEARBASKETOPEN]",0, $00,$68
  byte "[GEARBASKETCLOSE]",0, $00,$9A
  byte $FF

'INIT_handler
  '    var teamColor
  '    var x
  '    var y
  '	configure (out=D4, length=92, hasWhite=false)
  byte $09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ' 	defineColor(color=0,   W=0, R=0,   G=0,   B=0)    // Color 0  : Black    
  byte $09,$00,$01,$00,$00,$00,$00,$00,$00,$00,$64 '     defineColor(color=1,   W=0, R=0, G=0,   B=100)    // Color 1  : Blue
  byte $0A,$00,$01 '     solid(color=1)
  'HERE:
  byte $01,$03,$E8 ' 	pause(time=1000)
  byte $03,$FF,$FA ' 	goto(here) 
  byte $08 ' }

'[MODETELEOP]_handler
  byte $0A,$00,$00 ' 	solid(color=0)
  'HERE:
  byte $01,$13,$88 ' 	pause(time=5000)
  byte $03,$FF,$FA ' 	goto(here)
  byte $08 ' }

'[GEARBASKETOPEN]_handler
  byte $04,$01,$00,$00 '   [x] = 0
  byte $04,$02,$00,$2E '   [y] = 46
  'HERE:
  byte $02,$80,$01,$00,$01 '   set(pixel=[x],color=1)
  byte $02,$80,$02,$00,$01 '   set(pixel=[y],color=1)
  byte $01,$00,$64 '   pause(time=100)
  byte $05,$01,$20,$80,$01,$00,$01 '   [x] = [x] + 1
  byte $05,$02,$20,$80,$02,$00,$01 '   [y] = [y] + 1
  byte $06,$00,$03,$0C,$80,$01,$00,$2E '   if([x]<46)
  byte $03,$FF,$DA '     goto(here)
  '__gotoFail_0:
  'HERE2:
  byte $01,$03,$E8 ' 	pause(time=1000)
  byte $08 ' 	goto(here2) 

'[GEARBASKETCLOSE]_handler
  byte $04,$01,$00,$2D '   [x] = 45
  byte $04,$02,$00,$5B '   [y] = 91
  'HERE:
  byte $02,$80,$01,$00,$01 '   set(pixel=[x],color=1)
  byte $02,$80,$02,$00,$01 '   set(pixel=[y],color=1)
  byte $01,$00,$64 '   pause(time=100)
  byte $05,$01,$21,$80,$01,$00,$01 '   [x] = [x] - 1
  byte $05,$02,$21,$80,$02,$00,$01 '   [y] = [y] - 1
  byte $06,$00,$03,$01,$80,$02,$00,$2D '   if([y]>45)
  byte $03,$FF,$DA '     goto(here)
  '__gotoFail_0:
  'HERE2:
  byte $01,$03,$E8 ' 	pause(time=1000)
  byte $03,$FF,$FA ' 	goto(here2) 	
  byte $08 ' }

