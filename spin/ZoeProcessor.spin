pub init(prog)

'' Start the NeoPixel driver cog 
         
   return cognew(@ZoeCOG,prog)
   
DAT          
        org 0

ZoeCOG

' Setup our pointers into the header
               
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
        mov     stackPointer,p           ' ... callstack

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
' OPCODE 01 param  PAUSE(TIME=param)
        call    #GetParam                     ' Get the ...
        mov     pauseCounter,tmp              ' ... pause counter value
        call    #UpdateDisplay                ' Draw the display
        jmp     #mainLoop                     ' Back to wait for pause
                
notOp01 djnz    c,#notOp02  
' OPCODE 02 param param  SET(PIXEL=param,COLOR=param)
        call    #GetParam                     ' PIXEL=param        
        mov     p,tmp                         ' Hold pixel number
        add     p,par_buffer                  ' Pointer to pixel buffer
        call    #GetParam                     ' COLOR=param
        wrbyte  tmp,p                         ' Set the pixel value
        jmp     #command                      ' Run till pause

notOp02 djnz    c,#notOp03
' OPCODE 03 offset  GOTO(offset)
doGoto  call    #ReadWord                     ' Get the relative offset
doJump  add     programCounter,tmp            ' Add in the jump
        and     programCounter,C_FFFF         ' Mask to a word
        jmp     #command                      ' Run till pause

notOp03 djnz    c,#notOp04
' OPCODE 04 nn param SET(VARIABLE=nn, VALUE=param) 
        rdbyte  p,programCounter              ' Get the ... 
        add     programCounter,#1             ' ... variable number
        shl     p,#1                          ' Two bytes each
        add     p,variables                   ' Offset into variable table
        call    #GetParam                     ' Get the value
store   mov     val,tmp                       ' Write ...
        shr     val,#8                        ' ... the ...
        wrbyte  val,p                         ' ... MSB
        add     p,#1                          ' Write ...
        wrbyte  tmp,p                         ' ... LSB
        jmp     #command                      ' Run till pause

notOp04 djnz    c,#notOp05
' OPCODE 05 nn oo param param MATH(DST=nn, OP=oo, LEFT=param, RIGHT=param)
        rdbyte  p,programCounter              ' Get the ... 
        add     programCounter,#1             ' ... variable number
        shl     p,#1                          ' Two bytes each
        add     p,variables                   ' Offset into variable table
        rdbyte  val,programCounter            ' Get the ...
        add     programCounter,#1             ' ... operation number        
        call    #GetParam                     ' Get the ...
        mov     p2,tmp                        ' ... left value
        call    #GetParam                     ' Get the ...
        mov     c,tmp                         ' ... right value
        mov     tmp,p2                        ' We need the left value in tmp

        cmp     val,#0 wz                     ' Special case for ...
  if_z  jmp     #opMultiply                   ' ... multiply
        cmp     val,#1 wz                     ' Special case for ...
  if_z  jmp     #opDivide                     ' ... divide
        cmp     val,#2 wz                     ' Special case for ...
  if_z  jmp     #opModulo                     ' ... modulo

        ' Some operations
        '         MUL  00
        '         DIV  01
        '         MOD  02
        ' 10_0000 ADD  20
        ' 10_0001 SUB  21
        ' 10_1001 NEG  19 
        ' 01_1000 AND  18
        ' 01_1010 OR   1A
        ' 01_1011 XOR  1B
        ' 00_1011 SHL  0B
        ' 00_1010 SHR  0A

        'mov c,val
        'jmp #ErrorInC

        shl     val,#3                        ' Shift into INSTR position for MOVI
        or      val,#1                        ' Set R not fpr MOVI
        movi    mathOP,val                    ' Set the math operation
        nop                                   ' Required gap before using the modification
        '
mathOp  add     tmp,c                         ' Do the math
        '
        jmp     #store                        ' Store the result and run till pause

opMultiply
        mov     asm_x,tmp                     ' X ...
        mov     asm_y,c                       ' ... times ...
        call    #multiply                     ' ... Y
        mov     tmp,asm_x                     ' Result in X
        jmp     #store                        ' Store the result and run till pause
opDivide
        mov     asm_x,tmp                     ' X ...
        mov     asm_y,c                       ' ... divided by ...
        call    #sdiv32                       ' ... Y
        mov     tmp,asm_y                     ' Result in Y
        jmp     #store                        ' Store the result and run till pause
opModulo
        mov     asm_x,tmp                     ' X ...
        mov     asm_y,c                       ' ... divided by ...
        call    #sdiv32                       ' ... Y
        mov     tmp,asm_x                     ' Remainder in X
        jmp     #store                        ' Store the result and run till pause

notOp05 djnz    c,#notOp06
' OPCODE 06 mm ll op param param    (IF jumpIfNot, op, LEFT, RIGHT
        call    #ReadWord                     ' Offset to GOTO if expression failed
        mov     p,tmp                         ' Hold the offset in p for GOTO
        rdbyte  val,programCounter            ' Get the ...
        add     programCounter,#1             ' ... condition
        call    #GetParam                     ' Left operator
        mov     p2,tmp                        ' Hold in p2
        call    #GetParam                     ' Right operator 

        ' Some logic checks:
        ' 1010 ==   0A
        ' 0101 !=   05
        ' 0001 >    01
        ' 1100 <    0C
        ' 0011 >=   03
        ' 1110 <=   0E
                        
        ' No MOVC, so we'll do it manually
        andn    logicOp,C_003C0000            ' 003C0000 iiii_iiff_ffcc_ccdd_dddd_ddds_ssss_ssss
        shl     val,#18                       ' OR in ...
        or      logicOp,val                   ' ... the condition
        '
        cmp     p2,tmp wz, wc                 ' Compare left with right
        '
logicOp jmp     #command                      ' PASSES ... next instruction and run till pause
        '
        mov     tmp,p                         ' Offset if failed
        jmp     #doJump                       ' End of IF block and run till pause

notOp06 djnz    c,#notOp07
' OPCODE 07 mm ll    JSR
        mov     p, programCounter              ' Return is ...
        add     p, #2                          ' ... next instruction
        wrword  p,stackPointer                 ' Write the return (these are long aligned)
        add     stackPointer,#2                ' Slot for next time
        jmp     #doGoto                        ' Regular GOTO and run till pause        

notOp07 djnz    c,#notOp08
' OPCODE 08          RTS
        sub     stackPointer,#2                ' The last entry on the stack
        rdword  programCounter,stackPointer    ' Read the return address
        jmp     #command                       ' Run till pause

notOp08 djnz    c,#notOp09
' OPCODE 09 param, param, param, param  DEFCOLOR(slot,white,green,red,blue)
        call    #GetParam                ' Get the ...                      
        mov     p,tmp                    ' ... color slot number
        shl     p,#2                     ' Four bytes per slot
        add     p,par_palette            ' Offset into colors
        call    #GetParam                ' Get WHITE
        mov     c, tmp                   ' Accumulate the color here
        mov     p2,#3                    ' 3 more bytes to shift in
getCol  call    #GetParam                ' Get color component GREEN, RED, BLUE
        shl     c,#8                     ' Shift over existing value
        or      c,tmp                    ' OR in this byte
        djnz    p2,#getCol               ' Do all components        
        wrlong  c,p                      ' Write the color slot
        jmp     #command                 ' Run till pause        

notOp09 djnz    c,#notOp0A
' OPCODE 0A param  SOLID(color)
        call    #GetParam                ' Get the color number
        mov     p,par_buffer             ' Start of pixel buffer
        mov     c,par_pixCount           ' Number of pixels on strip
doStrip wrbyte  tmp,p                    ' Store color to buffer  
        add     p,#1                     ' Next in buffer
        djnz    c,#doStrip               ' Do all pixels
        jmp     #command                 ' Run till pause

notOp0A djnz    c,#notOp0B
' 0B nn ww hh .....           PATTERN(num=0,width=3,height=3, ...)
        rdbyte  p,programCounter         ' Pattern slot ...
        add     programCounter,#1        ' ... number
        shl     p,#1                     ' Two byte pointer
        add     p,patterns               ' Offset to pattern pointer
        wrword  programCounter,p         ' Set the pointer of this pattern
        rdbyte  asm_x,programCounter     ' Get the ...
        add     programCounter,#1        ' ... width
        rdbyte  asm_y,programCounter     ' Get the ...
        add     programCounter,#1        ' ... height
        call    #multiply                ' Total bytes in pattern
        add     programCounter,asm_x     ' Skip over pattern
        jmp     #command                 ' Run till pause

notOp0B djnz    c,#notOp0C
' 0C param param param param  DRAWPATTERN(num=0,x=2,y=4,coffset=0)
        call    #GetParam                ' Get the ...
        mov     p,tmp                    ' ... pattern slot
        shl     p,#1                     ' Two byte pointer
        add     p,patterns               ' Offset to pattern pointer
        rdword  p,p                      ' Get pointer to pattern
        call    #GetParam                ' Get the ...
        mov     asm_x,tmp                ' ... draw X
        call    #GetParam                ' Get the ...
        mov     asm_y,tmp                ' ... draw Y
        call    #GetParam                ' Get the ...
        mov     c,tmp                    ' ... color offset
        '
        rdbyte  width, p                 ' Get the ...
        add     p,#1                     ' ... pattern width
        rdbyte  height,p                 ' Get the ...
        add     p,#1                     ' ... pattern height
        '
        mov     tmp2,height              ' Row counter   
allRows
        mov     tmp,width                ' Column counter
allOfRow
        rdbyte  val,p                    ' Get the pixel value
        add     p,#1                     ' Next in pattern 
        add     val,c                    ' Color offset            
        call    #mapPixel                ' Set the pixel
        add     asm_x,#1                 ' Next X on row
        djnz    tmp,#allOfRow            ' Do all the pixels on the row
        sub     asm_x,width              ' Back up to beginning of row
        add     asm_y,#1                 ' Down to next row
        djnz    tmp2,#allRows            ' Do all the rows
        jmp     #command                 ' Run till pause        

mapPixel
' TODO for now, we'll assume left to right plates. In the future we need a way
' of handling random geometries
        mov     p2,#0                    ' Start at pixel 0
        mov     bitCnt,asm_x             ' We will mangle the X
wplates
        cmp     bitCnt,#8 wz, wc         ' A whole plate to skip?
 if_ae  add     p2,#64                   ' YES ... add in a plate to pix num
 if_ae  sub     bitCnt,#8                 ' YES ... subtract a plate from the X
 if_ae  jmp     #wplates                 ' YES ... keep skipping over plates
        mov     pixCnt,asm_y             ' Each row ...
        shl     pixCnt,#3                ' ... is 8 pixels
        add     pixCnt,bitCnt             ' Offset pixel across the row
        add     p2,pixCnt                ' Add in any whole plates
        add     p2,par_buffer            ' Offset into buffer
        wrbyte  val,p2                   ' Write the pixel
mapPixel_ret
        ret  

notOp0C
        mov     c,#%11110001             ' Unknown ...
        jmp     #ErrorInC                ' ... opcode 
        
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

'-------------------------------------
'signed multiply, taken from spin interpreter source
'-------------------------------------
'http://forums.parallax.com/forums/default.aspx?f=25&m=394199
' 32 to 64 bit signed multiply asm_x by asm_y
' asm_y absvaled, result in t1:asm_x
'
multiply
              abs       asm_x,asm_x  wc                  'abs(x)
              muxc      asm_n,#1                         'store sign of x
              abs       asm_y,asm_y  wc,wz               'abs(y)
        if_c  xor       asm_n,#1                         'store sign of y
              mov       t1,#0
              mov       t2,#32
              shr       asm_x,#1     wc
             
:mloop  if_c  add       t1,asm_y     wc
              rcr       t1,#1        wc
              rcr       asm_x,#1     wc
              djnz      t2,#:mloop
              test      asm_n,#1     wz
        if_nz neg       t1,t1                             'restore sign, upper 32 bits
        if_nz neg       asm_x,asm_x  wz                   'restore sign, lower 32 bits
        if_nz sub       t1,#1
             
multiply_ret  ret  

'-------------------------------------
'Signed divide, taken from spin interpreter
'-------------------------------------
'on entry: numerator in x, denominator/divisor in y
'on exit: division result in y, remainder in x
sdiv32                  abs     asm_x,asm_x     wc       'abs(x)
                        muxc    asm_n,#%11               'store sign of x
                        abs     asm_y,asm_y     wc,wz    'abs(y)
        if_c            xor     asm_n,#%10               'store sign of y

                        mov     t1,#0                    'unsigned divide
                        mov     t2,#32             
mdiv                    shr     asm_y,#1        wc,wz    
                        rcr     t1,#1
        if_nz           djnz    t2,#mdiv
mdiv2                   cmpsub  asm_x,t1        wc
                        rcl     asm_y,#1
                        shr     t1,#1
                        djnz    t2,#mdiv2

                        test    asm_n,#1        wc       'restore sign, remainder
                        negc    asm_x,asm_x              
                        test    asm_n,#%10      wc       'restore sign, division result
                        negc    asm_y,asm_y              
sdiv32_ret              ret

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

GetParam
        call    #ReadWord                ' Get the parameter
        andn    tmp,C_7FFF nr,wz         ' Is the upper bit set?
 if_z   jmp     #GetParam_ret            ' No ... we have the constant
        and     tmp, C_7FFF              ' Mask off upper bit
        shl     tmp, #1                  ' Two bytes each
        add     tmp,variables            ' Pointer to variables
        rdbyte  tmp2, tmp                ' Get ...
        add     tmp,#1                   ' ... MSB
        shl     tmp2,#8                  ' Into MSB
        rdbyte  tmp, tmp                 ' Get LSB
        or      tmp, tmp2                ' Combine in tmp
        
GetParam_ret
        ret
           
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
asm_x            long 0          ' Temporary 
asm_y            long 0          ' Temporary 
asm_n            long 0          ' Temporary 
t1               long 0          ' Temporary 
t2               long 0          ' Temporary 
width            long 0          ' Temporary 
height           long 0          ' Temporary 
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
C_7FFF           long $7FFF        ' Used to mask variable number
C_003C0000       long $003C0000
ONE              long 1            ' Used to WRBYTE
ZERO             long 0            ' Used to WRBYTE
ERRCOLOR0        long $00_00_00_08 ' Color for 0 bits in error
ERRCOLOR1        long $00_08_08_08 ' Color for 1 bits in error
ONE_MSEC         long 80_000       ' 80_000_000 clocks in a second / 1000

      FIT
      