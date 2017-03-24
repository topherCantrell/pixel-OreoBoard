pub getProgram
  return @zoeProgram

DAT
zoeProgram

'config
  byte 13
  byte 76
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
  byte 0,0,0,0,0,0,0,0,0,0,0,0

'events
  byte "INIT",0, $00,$44
  byte "[MODEAUTONOMOUSRED]",0, $01,$BD
  byte "[MODEAUTONOMOUSBLUE]",0, $01,$D2
  byte "[MODETELEOP]",0, $01,$E7
  byte $FF

'INIT_handler
  '    var teamColor
  '    var x
  '    var y
  '	configure (out=D3, length=76, hasWhite=true)
  byte $09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ' 	defineColor(color=0,   W=0, R=0,   G=0,   B=0)  	
  byte $09,$00,$01,$00,$00,$00,$0A,$00,$00,$00,$00 ' 	defineColor(color=1,   W=0, R=10,  G=0,   B=0)
  byte $09,$00,$02,$00,$00,$00,$14,$00,$00,$00,$00 ' 	defineColor(color=2,   W=0, R=20,  G=0,   B=0)
  byte $09,$00,$03,$00,$00,$00,$1E,$00,$00,$00,$00 ' 	defineColor(color=3,   W=0, R=30,  G=0,   B=0)
  byte $09,$00,$04,$00,$00,$00,$28,$00,$00,$00,$00 ' 	defineColor(color=4,   W=0, R=40,  G=0,   B=0)
  byte $09,$00,$05,$00,$00,$00,$32,$00,$00,$00,$00 ' 	defineColor(color=5,   W=0, R=50,  G=0,   B=0)
  byte $09,$00,$06,$00,$00,$00,$3C,$00,$00,$00,$00 ' 	defineColor(color=6,   W=0, R=60,  G=0,   B=0)
  byte $09,$00,$07,$00,$00,$00,$46,$00,$00,$00,$00 ' 	defineColor(color=7,   W=0, R=70,  G=0,   B=0)
  byte $09,$00,$08,$00,$00,$00,$50,$00,$00,$00,$00 ' 	defineColor(color=8,   W=0, R=80,  G=0,   B=0)
  byte $09,$00,$09,$00,$00,$00,$5A,$00,$00,$00,$00 ' 	defineColor(color=9,   W=0, R=90,  G=0,   B=0)
  byte $09,$00,$0A,$00,$00,$00,$64,$00,$00,$00,$00 ' 	defineColor(color=10,   W=0, R=100,  G=0,   B=0)
  byte $09,$00,$0B,$00,$00,$00,$6E,$00,$00,$00,$00 ' 	defineColor(color=11,   W=0, R=110,  G=0,   B=0)
  byte $09,$00,$0C,$00,$00,$00,$78,$00,$00,$00,$00 ' 	defineColor(color=12,   W=0, R=120,  G=0,   B=0)
  byte $09,$00,$0D,$00,$00,$00,$82,$00,$00,$00,$00 ' 	defineColor(color=13,   W=0, R=130,  G=0,   B=0)
  byte $09,$00,$0E,$00,$00,$00,$8C,$00,$00,$00,$00 ' 	defineColor(color=14,   W=0, R=140,  G=0,   B=0)
  byte $09,$00,$0F,$00,$00,$00,$96,$00,$00,$00,$00 ' 	defineColor(color=15,   W=0, R=150,  G=0,   B=0)
  byte $09,$00,$20,$00,$00,$00,$00,$00,$00,$00,$00 ' 	defineColor(color=32,   W=0, B=0,   G=0,   R=0)    
  byte $09,$00,$21,$00,$00,$00,$00,$00,$0A,$00,$00 ' 	defineColor(color=33,   W=0, B=10,  G=0,   R=0)
  byte $09,$00,$22,$00,$00,$00,$00,$00,$14,$00,$00 ' 	defineColor(color=34,   W=0, B=20,  G=0,   R=0)
  byte $09,$00,$23,$00,$00,$00,$00,$00,$1E,$00,$00 ' 	defineColor(color=35,   W=0, B=30,  G=0,   R=0)
  byte $09,$00,$24,$00,$00,$00,$00,$00,$28,$00,$00 ' 	defineColor(color=36,   W=0, B=40,  G=0,   R=0)
  byte $09,$00,$25,$00,$00,$00,$00,$00,$32,$00,$00 ' 	defineColor(color=37,   W=0, B=50,  G=0,   R=0)
  byte $09,$00,$26,$00,$00,$00,$00,$00,$3C,$00,$00 ' 	defineColor(color=38,   W=0, B=60,  G=0,   R=0)
  byte $09,$00,$27,$00,$00,$00,$00,$00,$46,$00,$00 ' 	defineColor(color=39,   W=0, B=70,  G=0,   R=0)
  byte $09,$00,$28,$00,$00,$00,$00,$00,$50,$00,$00 ' 	defineColor(color=40,   W=0, B=80,  G=0,   R=0)
  byte $09,$00,$29,$00,$00,$00,$00,$00,$5A,$00,$00 ' 	defineColor(color=41,   W=0, B=90,  G=0,   R=0)
  byte $09,$00,$2A,$00,$00,$00,$00,$00,$64,$00,$00 ' 	defineColor(color=42,   W=0, B=100,  G=0,   R=0)
  byte $09,$00,$2B,$00,$00,$00,$00,$00,$6E,$00,$00 ' 	defineColor(color=43,   W=0, B=110,  G=0,   R=0)
  byte $09,$00,$2C,$00,$00,$00,$00,$00,$78,$00,$00 ' 	defineColor(color=44,   W=0, B=120,  G=0,   R=0)
  byte $09,$00,$2D,$00,$00,$00,$00,$00,$82,$00,$00 ' 	defineColor(color=45,   W=0, B=130,  G=0,   R=0)
  byte $09,$00,$2E,$00,$00,$00,$00,$00,$8C,$00,$00 ' 	defineColor(color=46,   W=0, B=140,  G=0,   R=0)
  byte $09,$00,$2F,$00,$00,$00,$00,$00,$96,$00,$00 ' 	defineColor(color=47,   W=0, B=150,  G=0,   R=0)
  byte $09,$00,$14,$00,$32,$00,$32,$00,$32,$00,$00 ' 	defineColor(color=20,   W=0, R=50, B=50, G=50)
  byte $04,$00,$00,$00 ' 	[teamColor] = 0
  byte $0A,$00,$2F '     solid(color=47)
  'HERE:
  byte $01,$03,$E8 ' 	pause(time=1000)
  byte $03,$FF,$FA ' 	goto(here) 
  byte $08 ' }

'[MODEAUTONOMOUSRED]_handler
  byte $04,$00,$00,$00 ' 	[teamColor] = 0
  byte $05,$01,$20,$80,$00,$00,$0F ' 	[x] = [teamColor] + 15
  byte $0A,$80,$01 ' 	solid(color=[x])
  'HERE:
  byte $01,$13,$88 ' 	pause(time=5000)
  byte $03,$FF,$FA ' 	goto(here)
  byte $08 ' }

'[MODEAUTONOMOUSBLUE]_handler
  byte $04,$00,$00,$00 ' 	[teamColor] = 0
  byte $05,$01,$20,$80,$00,$00,$0F ' 	[x] = [teamColor] + 15
  byte $0A,$80,$01 ' 	solid(color=[x])
  'HERE:
  byte $01,$13,$88 ' 	pause(time=5000)
  byte $03,$FF,$FA ' 	goto(here)	
  byte $08 ' }

'[MODETELEOP]_handler
  'TOP:
  byte $04,$01,$00,$00 '     [x] = 0    
  byte $04,$02,$80,$00 '     [y] = [teamColor]
  'LOOP1:
  byte $0A,$80,$02 '     solid(color=[y])
  byte $01,$00,$FA '     pause(time=250)
  byte $05,$02,$20,$80,$02,$00,$01 '     [y] = [y] + 1    
  byte $05,$01,$20,$80,$01,$00,$01 '     [x] = [x] + 1
  byte $06,$00,$03,$0C,$80,$01,$00,$10 '     if([x]<16)
  byte $03,$FF,$E1 '       goto(loop1)
  '__gotoFail_0:
  'LOOP2:
  byte $0A,$80,$02 '     solid(color=[y])
  byte $01,$00,$FA '     pause(time=250)
  byte $05,$02,$21,$80,$02,$00,$01 '     [y] = [y] - 1
  byte $05,$01,$21,$80,$01,$00,$01 '     [x] = [x] - 1
  byte $06,$00,$03,$01,$80,$01,$00,$00 '     if([x]>0) 
  byte $03,$FF,$E1 '       goto(loop2)
  '__gotoFail_1:
  byte $03,$FF,$B7 '     goto(top)
  byte $08 ' }

