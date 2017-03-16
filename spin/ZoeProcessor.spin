pub init(prog)

'' Start the NeoPixel driver cog 
         
   return cognew(@ZoeCOG,prog)
   
DAT          
        org 0

ZoeCOG


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

        ' Run till a pause
        ' Update the screen
        ' Check the input buffer for an event and pause or stop


        ' Fetch command byte
        ' Decode
        
        mov     c,#%10110101       


ErrorInC
        mov      p, par_palette
        wrlong   ERRCOLOR0,p
        add      p,#4
        nop
        wrlong   ERRCOLOR1,p
        mov      val,#8
        shl      c,#24
        mov      p, par_buffer
errloop shl      c,#1 wc
  if_c  wrbyte   ONE,p
  if_nc wrbyte   ZERO,p
        add      p,#1
        djnz     val,#errloop

        call     #UpdateDisplay
errinf  jmp      #errinf
ONE     long     1
ZERO    long     0  


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
c                long 0          ' Counter used in delay
p                long 0          ' Pointer into pixel buffer
val              long 0          ' Shifting pixel value       
bitCnt           long 0          ' Counter for bit shifting
pixCnt           long 0          ' Counter for pixels in the strip
numBitsToSend    long 0          ' Either 32 bits (RGBW) or 24 bits (RGB)
'
C_RES            long $4B0       ' Wait count for latching the LEDs
'
ERRCOLOR0        long $00_00_00_08
ERRCOLOR1        long $00_08_08_08