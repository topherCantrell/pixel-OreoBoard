pub init(prog)

'' Start the NeoPixel driver cog 
         
   return cognew(@ZoeCOG,prog)
   
DAT          
        org 0

ZoeCOG

' TODO:
' - defcolor
' - variable parameters (including pause)
' - math
' - logic (IF)
' - Strip.solid
' - define pattern
' - Strip.drawPattern
'
' Other commands:
' - alternate(startColor,numColors)
' - pulse(ZOE function ... startColor, numColors, pause, passes)


' Setup the I/O pin
               
        mov     p,par                    ' Header in program data
        
        rdbyte  c,p                      ' Pin number
        add     p,#1                     ' Next byte
        mov     pn,#1                    ' Pin number                 
        
        rdbyte  par_pixCount,p           ' Pixels on the strand
        add     p,#1                     ' Next byte
        shl     pn,c                     ' This is our permanent pin mask  

        rdbyte  numBitsToSend,p          ' 24 (RGB) or 32 (RGBW)
        add     p,#1                     ' Next byte
        or      dira,pn                  ' Make sure we can write to our pin (here to kill time between rdbytes)

        rdbyte  numVars,p                ' Number of variables
        add     p,#1                     ' Next byte
        mov     eventInput,p             ' This is the event-input buffer

        add     p, #32                   ' Point to the ...
        mov     par_palette,p            ' ... color palette

        add     p, #64*4                 ' Skip to ...
        mov     patterns,p               ' ... patterns

        add     p, #16*2                 ' Skip to ...
        mov     callStack,p              ' ... callstack

        add     p, #32*2                 ' Skip to ...
        mov     variables,p              ' ... variables

        mov     c,numVars                ' Two bytes ...
        shl     c,#1                     ' ... per variable
        add     p,c                      ' Point to ...
        mov     par_buffer,p             ' ... pixel buffer

        add     p,par_pixCount           ' Point to ...
        mov     events,p                 ' ... event table
                
mainLoop
        rdbyte  c,eventInput wz          ' A new event?        
  if_nz jmp     #doEvent                 ' Yes ... go start it
        cmp     running, #1  wz          ' Are we running?
  if_nz jmp     #mainLoop                ' No ... wait for an event         
        mov     c, ONE_MSEC              ' Time to kill for 1 MSec
        add     c, cnt                   ' Offset from now
        waitcnt c,c                      ' Wait for 1 MSec  
        djnz    pauseCounter, #mainLoop  ' Wait all 1MSEC tics

command
        rdbyte  c,programCounter         ' Next ... 
        add     programCounter,#1        ' ... opcode

notOp00 djnz    c,#notOp01
' OPCODE 01 mm ll  PAUSE
        call    #ReadWord                     ' Get the ...
        mov     pauseCounter,tmp              ' ... pause counter value
        call    #UpdateDisplay                ' Draw the display
        jmp     #mainLoop                     ' Back to wait for pause
                
notOp01 djnz    c,#notOp02  
' OPCODE 02 aa bb  SET pixel A to color B            
        rdbyte  p,programCounter              ' Get the ...
        add     programCounter,#1             ' ... pixel number
        add     p,par_buffer                  ' Offset into memory
        rdbyte  c,programCounter              ' Get the ...
        add     programCounter,#1             ' ... color value
        wrbyte  c,p                           ' Set the pixel value
        jmp     #command                      ' Run untill pause

notOp02 djnz    c,#notOp03
' OPCODE 03 mm ll  GOTO
        call    #ReadWord                     ' Get the relative offset
        add     programCounter,tmp            ' Add in the jump
        and     programCounter,C_FFFF         ' Mask to a word
        jmp     #command                      ' Run untill pause

notOp03
        mov     c,#%11110001                  ' Unknown ...
        jmp     #ErrorInC                     ' ... opcode

ReadWord
        rdbyte  tmp,programCounter            ' Read ...
        add     programCounter,#1             ' ... MSB
        shl     tmp,#8                        ' Into position
        rdbyte  tmp2,programCounter           ' Read ...
        add     programCounter,#1             ' ... LSB
        or      tmp,tmp2                      ' Result is in tmp
ReadWord_ret
        ret                                   

' -------------------------------------------------------------------------------------------------
        
doEvent
        mov     p,events                 ' Pointer to events
doEvent2
        mov     p2,eventInput            ' Input buffer
        add     p2,#1                    ' Skip over trigger

        rdbyte  c,p wz                   ' Next in event table
        cmp     c,#$FF wz                ' Reached the end of the event table?
  if_nz jmp     #thisWord                ' No ... check the word
        wrbyte  ZERO,eventInput          ' Clear the trigger
        jmp     #mainLoop                ' Wait for next event

nextWord  
        cmp     c,#0 wz                  ' End of the current word in the table?
 if_z   jmp     #ne1                     ' Yes ... get ready for next check
        add     p,#1                     ' No ... read ...
        rdbyte  c,p                      ' ... next from table
        jmp     #nextWord                ' Check for ending now
        
ne1     add     p,#3                     ' Skip terminator plus pointer
        jmp     #doEvent2                ' Next word

thisWord
        rdbyte  c,p                      ' Next from ...
        add     p,#1                     ' ... table
        rdbyte  val,p2                   ' Next from ...          
        add     p2,#1                    ' ... input
        cmp     c,val wz                   ' Are they the same?
  if_nz jmp     #nextWord                ' No ... next table entry  
        cmp     c,#0 wz                  ' Terminator?
  if_nz jmp     #thisWord                ' No ... keep checking

       ' We found an event handler

        mov     programCounter,p         ' Routine reads from programCounter
        call    #ReadWord                ' Get the entry address
        add     tmp,events               ' Offset from the event table
        mov     programCounter,tmp       ' Start of event handler        
        wrbyte  ZERO,eventInput          ' Clear the trigger   
        mov     running,#1               ' Code is now running 
        jmp     #command                 ' Run till pause
        
' -------------------------------------------------------------------------------------------------   

ErrorInC
        mov      p, par_palette
        wrlong   ERRCOLOR0,p
        add      p,#4
        nop
        wrlong   ERRCOLOR1,p
        mov      val,#16
        shl      c,#16
        mov      p, par_buffer
errloop shl      c,#1 wc
  if_c  wrbyte   ONE,p
  if_nc wrbyte   ZERO,p
        add      p,#1
        djnz     val,#errloop
        call     #UpdateDisplay
        '
errinf  jmp      #errinf  

' -------------------------------------------------------------------------------------------------   

UpdateDisplay
        mov     p,par_buffer             ' Start of pixel buffer
        mov     pixCnt, par_pixCount
        
nextPixel        
        rdbyte  c,p                      ' Get the byte value
        add     p,#1                     ' Next pixel value 
doLook  shl     c,#2                     ' * 4 bytes per entry
        add     c,par_palette            ' Offset into palette
        rdlong  val,c                    ' Get pixel value         

        mov     bitCnt,numBitsToSend     ' 32 or 24 bits to move
        cmp     bitCnt, #24 wz           ' Is this a 3 byte value?
  if_z  shl     val, #8                  ' Yes ... ignore the upper 8    

bitLoop
        shl     val, #1 wc               ' MSB goes first
  if_c  jmp     #doOne                   ' Go send one if it is a 1
        call    #sendZero                ' It is a zero ... send a 0
        jmp     #bottomLoop              ' Skip over sending a 1
        '
doOne   call    #sendOne

bottomLoop
        djnz    bitCnt,#bitLoop          ' Do all bits in the pixel done?
        djnz    pixCnt,#nextPixel        ' Do all pixels on the strip
                
        call    #sendDone                ' Latch in the LEDs  

UpdateDisplay_ret
        ret                                

' These timing values were tweaked with an oscope
'        
sendZero                 
        or      outa,pn                  ' Take the data line high
        mov     c,#$5                    ' wait 0.4us (400ns)
loop3   djnz    c,#loop3                 '
        andn    outa,pn                  ' Take the data line low
        mov     c,#$B                    ' wait 0.85us (850ns) 
loop4   djnz    c,#loop4                 '                              
sendZero_ret                             '
        ret                              ' Done
'
sendOne
        or      outa,pn                  ' Take the data line high
        mov     c,#$D                    ' wait 0.8us 
loop1   djnz    c,#loop1                 '                       
        andn    outa,pn                  ' Take the data line low
        mov     c,#$3                    ' wait 0.45us  36 ticks, 9 instructions
loop2   djnz    c,#loop2                 '
sendOne_ret                              '
        ret                              ' Done
'
sendDone
        andn    outa,pn                  ' Take the data line low
        mov     c,C_RES                  ' wait 60us
loop5   djnz    c,#loop5                 '
sendDone_ret                             '
        ret                              ' Done  

' -------------------------------------------------------------------------------------------------     

running          long 0          ' 1 if there is an event running
pauseCounter     long 0          ' number of tics left in pause
eventInput       long 0          ' Pointer to event input
patterns         long 0          ' Pointer to patterns
callStack        long 0          ' Pointer to callstack
variables        long 0          ' Pointer to variables
events           long 0          ' Pointer to events
programCounter   long 0          ' Current PC
stackPointer     long 0          ' Current stack pointer
par_palette      long 0          ' Color palette (some commands) 
par_buffer       long 0          ' Pointer to the pixel data buffer
par_pixCount     long 0          ' Number of pixels
numVars          long 0          ' Number of variables on the strand
pn               long 0          ' Pin number bit mask
numBitsToSend    long 0          ' Either 32 bits (RGBW) or 24 bits (RGB)
'
c                long 0          ' Temporary
p                long 0          ' Temporary
val              long 0          ' Temporary
p2               long 0          ' Temporary
bitCnt           long 0          ' Temporary for bit shifting
pixCnt           long 0          ' Temporary for pixels in the strip
tmp              long 0          ' Temporary
tmp2             long 0          ' Temporary
'
C_RES            long $4B0         ' Wait count for latching the LEDs
C_FFFF           long $FFFF        ' Used to mask 2-byte signed numbers
ONE              long 1            ' Used to WRBYTE
ZERO             long 0            ' Used to WRBYTE
ERRCOLOR0        long $00_00_00_08 ' Color for 0 bits in error
ERRCOLOR1        long $00_08_08_08 ' Color for 1 bits in error
ONE_MSEC         long 80_000       ' 80_000_000 clocks in a second / 1000

      FIT
      