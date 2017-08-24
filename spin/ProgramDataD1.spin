pub getProgram
  return @zoeProgram

DAT
zoeProgram

'config
  byte 15
  byte 96
  byte 32
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
  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

'events
  byte "INIT",0, $00,$10
  byte "THROB",0, $00,$F3
  byte $FF

'INIT_handler
  '    configure (out=D1, length=96, hasWhite=true)
  byte $09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 '     defineColor(color=0,   W=0, R=0,  G=0,   B=0)   
  byte $09,$00,$01,$00,$00,$00,$00,$00,$14,$00,$00 '     defineColor(color=1,   W=0, R=0,  G=0,   B=20)
  byte $09,$00,$02,$00,$00,$00,$00,$00,$28,$00,$00 '     defineColor(color=2,   W=0, R=0,  G=0,   B=40)
  byte $09,$00,$03,$00,$00,$00,$00,$00,$3C,$00,$00 '     defineColor(color=3,   W=0, R=0,  G=0,   B=60)
  byte $09,$00,$04,$00,$00,$00,$00,$00,$50,$00,$00 '     defineColor(color=4,   W=0, R=0,  G=0,   B=80)
  byte $09,$00,$05,$00,$00,$00,$00,$00,$64,$00,$00 '     defineColor(color=5,   W=0, R=0,  G=0,   B=100)
  byte $09,$00,$06,$00,$00,$00,$00,$00,$6E,$00,$00 '     defineColor(color=6,   W=0, R=0,  G=0,   B=110)
  byte $09,$00,$07,$00,$00,$00,$00,$00,$78,$00,$00 '     defineColor(color=7,   W=0, R=0,  G=0,   B=120)
  byte $09,$00,$08,$00,$00,$00,$00,$00,$8C,$00,$00 '     defineColor(color=8,   W=0, R=0,  G=0,   B=140)
  byte $09,$00,$0B,$00,$00,$00,$14,$00,$00,$00,$00 '     defineColor(color=11,   W=0, B=0,  G=0,   R=20)
  byte $09,$00,$0C,$00,$00,$00,$28,$00,$00,$00,$00 '     defineColor(color=12,   W=0, B=0,  G=0,   R=40)
  byte $09,$00,$0D,$00,$00,$00,$3C,$00,$00,$00,$00 '     defineColor(color=13,   W=0, B=0,  G=0,   R=60)
  byte $09,$00,$0E,$00,$00,$00,$50,$00,$00,$00,$00 '     defineColor(color=14,   W=0, B=0,  G=0,   R=80)
  byte $09,$00,$0F,$00,$00,$00,$64,$00,$00,$00,$00 '     defineColor(color=15,   W=0, B=0,  G=0,   R=100)
  byte $09,$00,$10,$00,$00,$00,$6E,$00,$00,$00,$00 '     defineColor(color=16,   W=0, B=0,  G=0,   R=110)
  byte $09,$00,$11,$00,$00,$00,$78,$00,$00,$00,$00 '     defineColor(color=17,   W=0, B=0,  G=0,   R=120)
  byte $09,$00,$12,$00,$00,$00,$8C,$00,$00,$00,$00 '     defineColor(color=18,   W=0, B=0,  G=0,   R=140)
  '    var col
  '    var cnt
  '    var delay
  byte $04,$02,$00,$64 '     [delay] = 100
  'TOP:
  byte $04,$00,$00,$01 '     [col] = 1    
  byte $07,$00,$1D '     gosub(THROB)
  byte $07,$00,$1A '     gosub(THROB)
  byte $07,$00,$17 '     gosub(THROB)
  byte $07,$00,$14 '     gosub(THROB)
  byte $04,$00,$00,$0B '     [col] = 11
  byte $07,$00,$0D '     gosub(THROB)
  byte $07,$00,$0A '     gosub(THROB)
  byte $07,$00,$07 '     gosub(THROB)
  byte $07,$00,$04 '     gosub(THROB)
  byte $03,$FF,$DD '     goto(top)
  byte $08 ' }

'THROB_handler
  byte $04,$01,$00,$00 '     [cnt] = 0
  'THROBUP:
  byte $0A,$80,$00 '     solid(color=[col])
  byte $01,$80,$02 '     pause(time=[delay])
  byte $05,$00,$20,$80,$00,$00,$01 '     [col] = [col] + 1
  byte $05,$01,$20,$80,$01,$00,$01 '     [cnt] = [cnt] + 1  
  byte $06,$00,$03,$05,$80,$01,$00,$08 '     if([cnt]!=8)
  byte $03,$FF,$E1 '         goto(throbUp)
  '__gotoFail_0:
  'THROBDOWN:
  byte $05,$00,$21,$80,$00,$00,$01 '     [col] = [col] - 1
  byte $05,$01,$21,$80,$01,$00,$01 '     [cnt] = [cnt] - 1
  byte $0A,$80,$00 '     solid(color=[col])
  byte $01,$80,$02 '     pause(time=[delay])
  byte $06,$00,$03,$05,$80,$01,$00,$00 '     if([cnt]!=0)
  byte $03,$FF,$E1 '         goto(throbDown)  
  '__gotoFail_1:
  byte $08 '     return 
  byte $08 ' }

