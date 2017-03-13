  
var first = 0
var second = 1
  
function start() {

  // The D1 area is the bottom of the robot. It has 228 RGBW pixels
  configure(out=D1,length=228,hasWhite=true)
  
  // Define two colors: 0=red, 1=blue
  color(color=0,W=0, R=100, G=0, B=0)   // 100% red (no white, blue, or green) 
  color(color=1,W=0, R=0,   G=0, B=100) // 100% blue (no white, red, or green)
  color(color=2,W=0, R=100,   G=0, B=100) 
  color(color=3,W=0, R=0,   G=100, B=100) 
    
  here:   // Just a label
  
  first = 0
  second = 1
  blink()
  
  first = 2
  second = 3
  blink()
  
  goto(here)  // Endless loop
 
}

function blink() {
	
	Strip.color(color=[first])
	pause(time=1000)
	Strip.color(color=[second])
	pause(time=1000)
	
	return
}
  
  