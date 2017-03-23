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
  byte "INIT",0, $00,$B5
  byte "ALTERNATE",0, $01,$B9
  byte "JIGGLE",0, $01,$BA
  byte "SHRINKGROW",0, $01,$BB
  byte "[MODEAUTONOMOUSRED]",0, $01,$BC
  byte "[MODEAUTONOMOUSBLUE]",0, $01,$DB
  byte "[MODETELEOP]",0, $01,$FA
  byte "[GEARBASKETOPEN]",0, $02,$15
  byte "[GEARBASKETCLOSE]",0, $02,$30
  byte "[STOPCLIMB]",0, $02,$4B
  byte "[CLIMBUP]",0, $02,$66
  byte "[CLIMBDOWN]",0, $02,$81
  byte $FF

'INIT_handler
  '  var teamColor
  byte $04,$00,$00,$02 '   [teamColor] = 2 // Neutral
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
  byte $09,$00,$14,$00,$00,$00,$00,$00,$64,$00,$00 '   defineColor(color=20,  W=0, R=100, G=0, B=0) // Color 20 : Team Red
  byte $09,$00,$15,$00,$00,$00,$00,$00,$00,$00,$64 '   defineColor(color=21,  W=0, R=0, G=0, B=100) // Color 21 : Team Blue
  byte $09,$00,$16,$00,$00,$00,$05,$00,$05,$00,$05 '   defineColor(color=22,  W=0, R=5, G=5, B=5)   // Color 22 : Team Neutral
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
  byte $0A,$00,$00 '   solid(color=0)
  byte $0C,$00,$00,$00,$00,$00,$00,$00,$00 '   drawPattern(number=0,  x=0,  y=0)
  byte $0C,$00,$01,$00,$06,$00,$00,$00,$00 '   drawPattern(number=1,  x=6,  y=0)
  byte $0C,$00,$00,$00,$0C,$00,$00,$00,$00 '   drawPattern(number=0,  x=12, y=0)
  byte $0C,$00,$01,$00,$12,$00,$00,$00,$00 '   drawPattern(number=1,  x=18, y=0)
  'HERE:
  byte $01,$13,$88 ' 	  pause(time=5000)
  byte $03,$FF,$FA '   goto(here)
  byte $08 ' }

'ALTERNATE_handler
  byte $08 ' }

'JIGGLE_handler
  byte $08 ' }

'SHRINKGROW_handler
  byte $08 ' }

'[MODEAUTONOMOUSRED]_handler
  byte $04,$00,$00,$14 ' 	[teamColor] = 20
  byte $02,$00,$38,$80,$00 ' 	set(pixel=56,color=[teamColor])
  byte $02,$00,$39,$00,$16 ' 	set(pixel=57,color=22)
  byte $02,$00,$3A,$00,$16 ' 	set(pixel=58,color=22)
  byte $02,$00,$3B,$00,$16 ' 	set(pixel=59,color=22)
  'HERE:
  byte $01,$13,$88 ' 	pause(time=5000)
  byte $03,$FF,$FA ' 	goto(here)
  byte $08 ' }

'[MODEAUTONOMOUSBLUE]_handler
  byte $04,$00,$00,$15 ' 	[teamColor] = 21
  byte $02,$00,$38,$80,$00 ' 	set(pixel=56,color=[teamColor])
  byte $02,$00,$39,$00,$16 ' 	set(pixel=57,color=22)
  byte $02,$00,$3A,$00,$16 ' 	set(pixel=58,color=22)
  byte $02,$00,$3B,$80,$00 ' 	set(pixel=59,color=[teamColor])
  'HERE:
  byte $01,$13,$88 ' 	pause(time=5000)
  byte $03,$FF,$FA ' 	goto(here)
  byte $08 ' }

'[MODETELEOP]_handler
  byte $02,$00,$38,$80,$00 ' 	set(pixel=56,color=[teamColor])
  byte $02,$00,$39,$00,$16 ' 	set(pixel=57,color=22)
  byte $02,$00,$3A,$80,$00 ' 	set(pixel=58,color=[teamColor])
  byte $02,$00,$3B,$00,$16 ' 	set(pixel=59,color=22)
  'HERE:
  byte $01,$13,$88 ' 	pause(time=5000)
  byte $03,$FF,$FA ' 	goto(here)
  byte $08 ' }

'[GEARBASKETOPEN]_handler
  byte $02,$00,$38,$80,$00 ' 	set(pixel=56,color=[teamColor])
  byte $02,$00,$39,$00,$16 ' 	set(pixel=57,color=22)
  byte $02,$00,$3A,$80,$00 ' 	set(pixel=58,color=[teamColor])
  byte $02,$00,$3B,$80,$00 ' 	set(pixel=59,color=[teamColor])
  'HERE:
  byte $01,$13,$88 ' 	pause(time=5000)
  byte $03,$FF,$FA ' 	goto(here)
  byte $08 ' }

'[GEARBASKETCLOSE]_handler
  byte $02,$00,$38,$80,$00 ' 	set(pixel=56,color=[teamColor])
  byte $02,$00,$39,$80,$00 ' 	set(pixel=57,color=[teamColor])
  byte $02,$00,$3A,$00,$16 ' 	set(pixel=58,color=22)
  byte $02,$00,$3B,$00,$16 ' 	set(pixel=59,color=22)
  'HERE:
  byte $01,$13,$88 ' 	pause(time=5000)
  byte $03,$FF,$FA ' 	goto(here)
  byte $08 ' }

'[STOPCLIMB]_handler
  byte $02,$00,$38,$80,$00 ' 	set(pixel=56,color=[teamColor])
  byte $02,$00,$39,$80,$00 ' 	set(pixel=57,color=[teamColor])
  byte $02,$00,$3A,$00,$16 ' 	set(pixel=58,color=22)
  byte $02,$00,$3B,$80,$00 ' 	set(pixel=59,color=[teamColor])
  'HERE:
  byte $01,$13,$88 ' 	pause(time=5000)
  byte $03,$FF,$FA ' 	goto(here)
  byte $08 ' }

'[CLIMBUP]_handler
  byte $02,$00,$38,$80,$00 ' 	set(pixel=56,color=[teamColor])
  byte $02,$00,$39,$80,$00 ' 	set(pixel=57,color=[teamColor])
  byte $02,$00,$3A,$80,$00 ' 	set(pixel=58,color=[teamColor])
  byte $02,$00,$3B,$00,$16 ' 	set(pixel=59,color=22)
  'HERE:
  byte $01,$13,$88 ' 	pause(time=5000)
  byte $03,$FF,$FA ' 	goto(here)
  byte $08 ' }

'[CLIMBDOWN]_handler
  byte $02,$00,$38,$80,$00 ' 	set(pixel=56,color=[teamColor])
  byte $02,$00,$39,$80,$00 ' 	set(pixel=57,color=[teamColor])
  byte $02,$00,$3A,$80,$00 ' 	set(pixel=58,color=[teamColor])
  byte $02,$00,$3B,$80,$00 ' 	set(pixel=59,color=[teamColor])
  'HERE:
  byte $01,$13,$88 ' 	pause(time=5000)
  byte $03,$FF,$FA ' 	goto(here)
  byte $08 ' }

