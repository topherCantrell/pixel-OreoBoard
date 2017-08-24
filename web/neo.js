var NEO = (function() {
	
	var OFFS = [[0,-1],[1,0],[0,1],[-1,0]];
	
	var my = {};
			
	my.cursor = {}
	
	my.setCursor = function(x,y,strip,radius,gap,number) {		
		my.cursor.x = x;
		my.cursor.y = y;
		if(strip!==undefined) my.cursor.strip = strip;
		if(radius!==undefined) my.cursor.radius = radius;
		if(gap!==undefined) my.cursor.gap = gap;
		if(number!==undefined) my.cursor.number = number;
	};
	
	my.makeStrip = function(direction,length) {				
		
		var strips = $("#oreoZoe_D"+my.cursor.strip);
		var ox = OFFS[direction][0];
		var oy = OFFS[direction][1];	
		for(var z=0;z<length;++z) {		
			strips.append("<circle "+
					"id='D"+my.cursor.strip+"_"+(my.cursor.number)+"' "+
					"cx='"+(my.cursor.x)+"' "+
					"cy='"+(my.cursor.y)+"' "+
					"r='"+my.cursor.radius+"' "+
					"stroke='#E0E0E0' stroke-width='1' "+
					"fill='#F8F8F8'/>");
			my.cursor.x += ox*my.cursor.gap;
			my.cursor.y += oy*my.cursor.gap;
			++my.cursor.number;
		}
		$("#oreoZoe_D"+my.cursor.strip).html($("#oreoZoe_D"+my.cursor.strip).html());
	};
	
	my.setLED = function(stripNumber,number,color) {		
		$("#S"+stripNumber+"_"+number).attr("fill",color);
	};
	
	return my;

}());

function makeSquare(strip,x,y,snum) {
	NEO.setCursor(x,y, strip,4,15,snum);
	NEO.makeStrip(1,22);
	NEO.setCursor(NEO.cursor.x-5,NEO.cursor.y+10);
	NEO.makeStrip(2,16);
	NEO.setCursor(NEO.cursor.x-10,NEO.cursor.y-5);
	NEO.makeStrip(3,22);
	NEO.setCursor(NEO.cursor.x+5,NEO.cursor.y-10);
	NEO.makeStrip(0,16);
}

// D1 Border
makeSquare(1,50,10, 0);

// D2 Circle
NEO.setCursor(10,10, 2,4,20,0);
NEO.makeStrip(1,24);

// D3 Strip
NEO.setCursor(10,10, 3,4,10,0);
NEO.makeStrip(1,22);

// D4 Grid
NEO.setCursor(10,10, 4,4,15,0);
for(var z=0;z<3;++z) {
	for(var y=0;y<8;++y) {
		NEO.setCursor(10+120*z,10+y*15);
		NEO.makeStrip(1,8);
	}
}

var proc1 = initZoeProcessor($("#oreoZoe_D1"),$("#code_D1").val());
var proc2 = initZoeProcessor($("#oreoZoe_D2"),$("#code_D2").val());
var proc3 = initZoeProcessor($("#oreoZoe_D3"),$("#code_D3").val()); 
var proc4 = initZoeProcessor($("#oreoZoe_D4"),$("#code_D4").val());

$("#stop_D1").bind("click",function() { 
    proc1.stop();   
});
$("#stop_D2").bind("click",function() { 
    proc2.stop();   
});
$("#stop_D3").bind("click",function() { 
    proc3.stop();    
 });
$("#stop_D4").bind("click",function() { 
    proc4.stop();
});


$(".zoeEvent").bind("click",function() {
    var t = $(this);    
    if(t.hasClass("D1")) {
        if(t.text().toUpperCase()==="INIT") {
            proc1.reset($("#code_D1").val()); 
        }
        proc1.event(t.text());
    }  
    if(t.hasClass("D2")) {
        if(t.text().toUpperCase()==="INIT") {
            proc2.reset($("#code_D2").val()); 
        }
        proc2.event(t.text());
    }     
    if(t.hasClass("D3")) {
        if(t.text().toUpperCase()==="INIT") {
            proc3.reset($("#code_D3").val()); 
        }
        proc3.event(t.text());
    } 
    if(t.hasClass("D4")) {
        if(t.text().toUpperCase()==="INIT") {
            proc4.reset($("#code_D4").val()); 
        }
        proc4.event(t.text());
    } 
});





