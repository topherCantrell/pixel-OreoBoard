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
		
		var strips = $(".oreoZoe_D"+my.cursor.strip);
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
		$(".oreoZoe_D"+my.cursor.strip).html($(".oreoZoe_D"+my.cursor.strip).html());
	};
	
	my.setLED = function(stripNumber,number,color) {		
		$("#S"+stripNumber+"_"+number).attr("fill",color);
	};
	
	my.makeSquare = function(strip,x,y,len,wid,gap,snum) {
		my.setCursor(x,y, strip,4,gap,snum);
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

		if($(".oreoZoe_D1").length) proc1 = initZoeProcessor($(".oreoZoe_D1"),$("#code_D1").val());
		if($(".oreoZoe_D2").length) proc2 = initZoeProcessor($(".oreoZoe_D2"),$("#code_D2").val());
		if($(".oreoZoe_D3").length) proc3 = initZoeProcessor($(".oreoZoe_D3"),$("#code_D3").val()); 
		if($(".oreoZoe_D4").length) proc4 = initZoeProcessor($(".oreoZoe_D4"),$("#code_D4").val());

		$(".zoeEvent").bind("click",function() {
		 var t = $(this);
		 
		 // TODO allow multiple matches
		 
		 var isStop = t.hasClass("stop");
		 var isInit = t.hasClass("init");
		 
		 if(t.hasClass("D1")) {
			 if(isStop) {
			 	proc1.stop();
			 } 
			 if(isInit) {
			 	proc1.reset($("#code_D1").val());
			 } 
			 proc1.event(t.text());			 
		 }
		 if(t.hasClass("D2")) {
			 if(isStop) {
			 	proc2.stop();
			 } 
			 if(isInit) {
			 	proc2.reset($("#code_D2").val());
			 } 
			 proc2.event(t.text());			 
		 }
		 if(t.hasClass("D3")) {
			 if(isStop) {
			 	proc3.stop();
			 }
			 if(isInit) {
			 	proc3.reset($("#code_D3").val());
			 } 
			 proc3.event(t.text());			 
		 }
		 if(t.hasClass("D4")) {
			 if(isStop) {
			 	proc4.stop();
			 } 
			 if(isInit) {
			 	proc4.reset($("#code_D4").val());
			 } 
			 proc4.event(t.text());			 
		 }		 
		 
		});
	}
	
	return my;

}());
