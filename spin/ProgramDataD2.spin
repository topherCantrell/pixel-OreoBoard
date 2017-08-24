pub getProgram
  return @zoeProgram

DAT
zoeProgram

'config
  byte 14
  byte 24
  byte 32
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
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

'events
  byte "INIT",0, $00,$08
  byte $FF

'INIT_handler
  '      configure (out=D2, length=24, hasWhite=true)   
  byte $09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 '       defineColor(color=0,   W=0, R=0,   G=0,   B=0)    
  byte $09,$00,$01,$00,$00,$00,$00,$00,$64,$00,$00 '       defineColor(color=1,   W=0, R=0,  G=0,   B=100)
  '      var x
  '      var delay
  byte $04,$00,$00,$00 '       [x] = 0
  byte $04,$01,$00,$32 '       [delay] = 50
  'TOP:
  byte $0A,$00,$00 '     solid(color=0)
  byte $02,$80,$00,$00,$01 '     set(pixel=[x],color=1)
  byte $01,$80,$01 '     pause(time=[delay])
  byte $05,$00,$20,$80,$00,$00,$01 '     [x] = [x] + 1
  byte $06,$00,$04,$0A,$80,$00,$00,$18 '     if([x]==24)
  byte $04,$00,$00,$00 '       [x] = 0
  '__gotoFail_0:
  byte $03,$FF,$DF '     goto(top)
  byte $08 '   }

