pub getProgram
  return @zoeProgram

DAT
zoeProgram

'config
  byte 12
  byte 8
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
  byte 0,0,0,0,0,0,0,0

'events
  byte "INIT",0, $00,$08
  byte $FF

'INIT_handler
  '	configure (out=D4, length=8, hasWhite=false)
  'HERE:
  byte $01,$03,$E8 ' 		pause(time=1000)
  byte $03,$FF,$FA ' 		goto(here) 
  byte $08 ' }

