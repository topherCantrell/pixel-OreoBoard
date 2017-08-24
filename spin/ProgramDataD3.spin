pub getProgram
  return @zoeProgram

DAT
zoeProgram

'config
  byte 13
  byte 22
  byte 24
  byte 2

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
  word 0,0

'pixbuffer ' 1 byte per pixel
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

'events
  byte "INIT",0, $00,$08
  byte $FF

'INIT_handler
  '      configure (out=D3, length=22, hasWhite=false)
  byte $09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 '       defineColor(color=0,   W=0, R=0,   G=0,   B=0)    
  byte $09,$00,$01,$00,$00,$00,$64,$00,$00,$00,$64 '       defineColor(color=1,   W=0, R=0,  G=100,   B=100)
  '      var delay
  '      var x
  byte $04,$00,$00,$14 '       [delay] = 20
  byte $0A,$00,$00 '       solid(color=0)
  'TOP:
  byte $04,$01,$00,$00 '     [x] = 0
  'ON:
  byte $02,$80,$01,$00,$01 '     set(pixel=[x],color=1)
  byte $01,$80,$00 '     pause(time=[delay])
  byte $05,$01,$20,$80,$01,$00,$01 '     [x] = [x] + 1
  byte $06,$00,$03,$05,$80,$01,$00,$16 '     if([x]!=22)
  byte $03,$FF,$E6 '         goto(on)
  '__gotoFail_0:
  byte $01,$03,$E8 ' pause(time=1000)
  'OFF:
  byte $02,$80,$01,$00,$00 '     set(pixel=[x],color=0)
  byte $01,$80,$00 ' pause(time=[delay])
  byte $05,$01,$21,$80,$01,$00,$01 ' [x] = [x] - 1
  byte $06,$00,$03,$05,$80,$01,$00,$00 ' if([x]!=0)
  byte $03,$FF,$E6 '     goto(off)
  '__gotoFail_1:
  byte $0A,$00,$00 ' solid(color=0)
  byte $01,$03,$E8 ' pause(time=1000)
  byte $03,$FF,$BC ' goto(top)
  byte $08 '   }

