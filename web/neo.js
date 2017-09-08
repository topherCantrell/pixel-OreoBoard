var NEO = (function() {
	
	var OFFS = [[0,-1],[1,0],[0,1],[-1,0]];
	
	var procs = [null, null, null, null];
	
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
	
	my.makeSquare = function(strip,x,y,len,wid,snum) {
		my.setCursor(x,y, strip,4,15,snum);
		my.makeStrip(1,len);
		my.setCursor(NEO.cursor.x-5,NEO.cursor.y+10);
		my.makeStrip(2,wid);
		my.setCursor(NEO.cursor.x-10,NEO.cursor.y-5);
		my.makeStrip(3,len);
		my.setCursor(NEO.cursor.x+5,NEO.cursor.y-10);
		my.makeStrip(0,wid);
	}
	
	my.initProcessors = function() {
		//svg id "oreoZoe_D1" with text area id "code_D1"
		//Buttons have classes:
		//
		//class="zoeEvent D1 stop"  - the STOP button
		//class="zoeEvent D1 init"  - the INIT button (reset then INIT script)
		//class="zoeEvent D1"       - whatever the text is becomes the event call

		if($("#oreoZoe_D1").length) proc1 = initZoeProcessor($("#oreoZoe_D1"),$("#code_D1").val());
		if($("#oreoZoe_D2").length) proc2 = initZoeProcessor($("#oreoZoe_D2"),$("#code_D2").val());
		if($("#oreoZoe_D3").length) proc3 = initZoeProcessor($("#oreoZoe_D3"),$("#code_D3").val()); 
		if($("#oreoZoe_D4").length) proc4 = initZoeProcessor($("#oreoZoe_D4"),$("#code_D4").val());

		$(".zoeEvent").bind("click",function() {
		 var t = $(this);
		 
		 var isStop = t.hasClass("stop");
		 var isInit = t.hasClass("init");
		 var strip;
		 var proc;
		 if(t.hasClass("D1")) {
		 	strip="D1";
		 	proc = proc1;
		 }
		 if(t.hasClass("D2")) {
		 	strip="D2";
		 	proc = proc2;
		 }
		 if(t.hasClass("D3")) {
		 	strip="D3";
		 	proc = proc3;
		 }
		 if(t.hasClass("D4")) {
		 	strip="D4";
		 	proc = proc4;
		 }
		 
		 if(isStop) {
		 	proc.stop();
		 	return;
		 }
		 
		 if(isInit) {
		 	proc.reset($("#code_"+strip).val());
		 }
		 proc.event(t.text());
		     
		});
	}
	
	return my;

}());
