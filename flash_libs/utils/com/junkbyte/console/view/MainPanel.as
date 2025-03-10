﻿/*
* 
* Copyright (c) 2008-2010 Lu Aye Oo
* 
* @author 		Lu Aye Oo
* 
* http://code.google.com/p/flash-console/
* 
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
* 
*/

package com.junkbyte.console.view 
{
	import com.junkbyte.console.Console;
	import com.junkbyte.console.core.LogReferences;
	import com.junkbyte.console.core.Remoting;
	import com.junkbyte.console.vos.Log;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	public class MainPanel extends AbstractPanel {
		
		public static const NAME:String = "mainPanel";
		
		private static const CL_HISTORY:String = "clhistory";
		
		private var _traceField:TextField;
		private var _cmdPrefx:TextField;
		private var _cmdField:TextField;
		private var _hintField:TextField;
		private var _cmdBG:Shape;
		private var _bottomLine:Shape;
		private var _mini:Boolean;
		private var _shift:Boolean;
		private var _ctrl:Boolean;
		
		private var _scroll:Sprite;
		private var _scroller:Sprite;
		private var _scrolldelay:uint;
		private var _scrolldir:int;
		private var _scrolling:Boolean;
		private var _scrollHeight:Number;
		private var _selectionStart:int;
		private var _selectionEnd:int;
		
		private var _viewingChannels:Array;
		private var _extraMenus:Object = new Object();
		private var _cmdsInd:int = -1;
		private var _priority:int;
		private var _filterText:String;
		private var _filterRegExp:RegExp;
		private var _clScope:String = "";
		
		private var _needUpdateMenu:Boolean;
		private var _needUpdateTrace:Boolean;
		private var _lockScrollUpdate:Boolean;
		private var _atBottom:Boolean = true;
		private var _enteringLogin:Boolean;
		
		private var _hint:String;
		
		private var _cmdsHistory:Array;
		
		public function MainPanel(m:Console) {
			super(m);
			var fsize:int = style.menuFontSize;
			_viewingChannels = new Array();
			
			console.cl.addCLCmd("filter", setFilterText, "Filter console logs to matching string. When done, click on the * (global channel) at top.", true);
			console.cl.addCLCmd("filterexp", setFilterRegExp, "Filter console logs to matching regular expression", true);
			console.cl.addCLCmd("clearhistory", clearCommandLineHistory, "Clear history of commands you have entered.", true);

			name = NAME;
			minWidth = 50;
			minHeight = 18;
			
			_traceField = makeTF("traceField");
			_traceField.wordWrap = true;
			_traceField.multiline = true;
			_traceField.y = fsize;
			_traceField.addEventListener(Event.SCROLL, onTraceScroll);
			addChild(_traceField);
			//
			txtField = makeTF("menuField");
			txtField.height = fsize+6;
			txtField.y = -2;
			registerTFRoller(txtField, onMenuRollOver);
			addChild(txtField);
			//
			_cmdBG = new Shape();
			_cmdBG.name = "commandBackground";
			_cmdBG.graphics.beginFill(style.commandLineColor, 0.1);
			_cmdBG.graphics.drawRoundRect(0, 0, 100, 18,fsize,fsize);
			_cmdBG.scale9Grid = new Rectangle(9, 9, 80, 1);
			addChild(_cmdBG);
			//
			var tf:TextFormat = new TextFormat(style.menuFont, style.menuFontSize, style.highColor);
			_cmdField = new TextField();
			_cmdField.name = "commandField";
			_cmdField.type  = TextFieldType.INPUT;
			_cmdField.x = 40;
			_cmdField.height = fsize+6;
			_cmdField.addEventListener(KeyboardEvent.KEY_DOWN, commandKeyDown);
			_cmdField.addEventListener(KeyboardEvent.KEY_UP, commandKeyUp);
			_cmdField.addEventListener(FocusEvent.FOCUS_IN, updateCmdHint);
			_cmdField.addEventListener(FocusEvent.FOCUS_OUT, onCmdFocusOut);
			_cmdField.defaultTextFormat = tf;
			addChild(_cmdField);
			
			_hintField = new TextField();
			_hintField.name = "commandField";
			_hintField.mouseEnabled = false;
			_hintField.background = true;
			_hintField.backgroundColor = style.backgroundColor;
			_hintField.defaultTextFormat = new TextFormat(style.menuFont, style.menuFontSize-1, style.lowColor);
			_hintField.x = _cmdField.x;
			_hintField.width = 300;
			_hintField.autoSize = TextFieldAutoSize.LEFT;
			addChild(_hintField);
			setHints();
			
			tf.color = style.commandLineColor;
			_cmdPrefx = new TextField();
			_cmdPrefx.name = "commandPrefx";
			_cmdPrefx.type  = TextFieldType.DYNAMIC;
			_cmdPrefx.x = 2;
			_cmdPrefx.height = fsize+6;
			_cmdPrefx.selectable = false;
			_cmdPrefx.defaultTextFormat = tf;
			_cmdPrefx.addEventListener(MouseEvent.MOUSE_DOWN, onCmdPrefMouseDown);
			_cmdPrefx.addEventListener(MouseEvent.MOUSE_MOVE, onCmdPrefRollOverOut);
			_cmdPrefx.addEventListener(MouseEvent.ROLL_OUT, onCmdPrefRollOverOut);
			addChild(_cmdPrefx);
			//
			_bottomLine = new Shape();
			_bottomLine.name = "blinkLine";
			_bottomLine.alpha = 0.2;
			addChild(_bottomLine);
			//
			_scroll = new Sprite();
			_scroll.y = fsize+4;
			_scroll.name = "scroller";
			_scroll.buttonMode = true;
			_scroll.addEventListener(MouseEvent.MOUSE_DOWN, onScrollbarDown, false, 0, true);
			_scroller = new Sprite();
			_scroller.name = "scrollbar";
			_scroller.y = 5;
			_scroller.graphics.beginFill(style.controlColor, 1);
			_scroller.graphics.drawRect(-5, 0, 5, 30);
			_scroller.graphics.beginFill(0, 0);
			_scroller.graphics.drawRect(-10, 0, 10, 30);
			_scroller.graphics.endFill();
			_scroller.addEventListener(MouseEvent.MOUSE_DOWN, onScrollerDown, false, 0, true);
			_scroll.addChild(_scroller);
			addChild(_scroll);
			//
			_cmdField.visible = false;
			_cmdPrefx.visible = false;
			_cmdBG.visible = false;
			updateCLScope("");
			//
			init(640,100,true);
			registerDragger(txtField);
			//
			if(console.so[CL_HISTORY] is Array){
				_cmdsHistory = console.so[CL_HISTORY];
			}else{
				console.so[CL_HISTORY] = _cmdsHistory = new Array();
			}
			//
			addEventListener(TextEvent.LINK, linkHandler, false, 0, true);
			addEventListener(Event.ADDED_TO_STAGE, stageAddedHandle, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle, false, 0, true);
		}
		public function addMenu(key:String, f:Function, args:Array, rollover:String):void{
			if(key){
				key = key.replace(/[^\w]*/g, "");
				if(f == null){
					delete _extraMenus[key];
				}else{
					// used to use ExternalMenu Class, but that adds extra 0.3kb.
					_extraMenus[key] = new Array(f, args, rollover);
				}
				_needUpdateMenu = true;
			}else console.report("ERROR: Invalid add menu params.", 9);
		}
		private function stageAddedHandle(e:Event=null):void{
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, 0, true);
		}
		private function stageRemovedHandle(e:Event=null):void{
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		private function onCmdPrefRollOverOut(e : MouseEvent) : void {
			console.panels.tooltip(e.type==MouseEvent.MOUSE_MOVE?"Current scope::(CommandLine)":"", this);
		}
		private function onCmdPrefMouseDown(e : MouseEvent) : void {
			try{
				stage.focus = _cmdField;
				_cmdField.setSelection(_cmdField.text.length, _cmdField.text.length);
			} catch(err:Error) {}
		}
		private function keyDownHandler(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.SHIFT){
				_shift = true;
			}
			if (e.keyCode == Keyboard.CONTROL) {
				_ctrl = true;
			}
		}
		private function keyUpHandler(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.SHIFT){
				_shift = false;
			}else if(e.keyCode == Keyboard.CONTROL){
				_ctrl = false;
			}else if(e.keyCode == Keyboard.ENTER && parent.visible && visible && _cmdField.visible){
				try{
					stage.focus = _cmdField;
					_cmdField.setSelection(0, _cmdField.text.length);
				} catch(err:Error) {}
			}
		}
		
		public function requestLogin(on:Boolean = true):void{
			var ct:ColorTransform = new ColorTransform();
			if(on){
				console.commandLine = true;
				console.report("//", -2);
				console.report("// <b>Enter remoting password</b> in CommandLine below...", -2);
				updateCLScope("Password");
				ct.color = style.controlColor;
				_cmdBG.transform.colorTransform = ct;
				_traceField.transform.colorTransform = new ColorTransform(0.7,0.7,0.7);
			}else{
				updateCLScope("");
				_cmdBG.transform.colorTransform = ct;
				_traceField.transform.colorTransform = ct;
			}
			_cmdField.displayAsPassword = on;
			_enteringLogin = on;
		}
		public function update(changed:Boolean):void{
			if(_bottomLine.alpha>0){
				_bottomLine.alpha -= 0.25;
			}
			if(_clScope != console.cl.scopeString && console.remoter.remoting != Remoting.RECIEVER){
				_clScope = console.cl.scopeString;
				updateCLScope(_clScope);
			}
			if(changed){
				_bottomLine.alpha = 1;
				_needUpdateMenu = true;
				_needUpdateTrace = true;
			}
			if(_needUpdateTrace){
				_needUpdateTrace = false;
				_updateTraces(true);
			}
			if(_needUpdateMenu){
				_needUpdateMenu = false;
				_updateMenu();
			}
		}
		public function updateToBottom():void{
			_atBottom = true;
			_needUpdateTrace = true;
		}
		private function _updateTraces(onlyBottom:Boolean = false):void{
			if(_atBottom) {
				updateBottom(); 
			}else if(!onlyBottom){
				updateFull();
			}
			if(_selectionStart != _selectionEnd){
				if(_atBottom){
					_traceField.setSelection(_traceField.text.length-_selectionStart, _traceField.text.length-_selectionEnd);
				}else{
					_traceField.setSelection(_traceField.text.length-_selectionEnd, _traceField.text.length-_selectionStart);
				}
				_selectionEnd = -1;
				_selectionStart = -1;
			}
		}
		private function updateFull():void{
			var str:String = "";
			var line:Log = console.logs.last;
			while(line){
				if(lineShouldShow(line)){
					str = makeLine(line)+str;
				}
				line = line.prev;
			}
			_lockScrollUpdate = true;
			_traceField.htmlText = str;
			_lockScrollUpdate = false;
			updateScroller();
		}
		public function setPaused(b:Boolean):void{
			if(b && _atBottom){
				_atBottom = false;
				_updateTraces();
				_traceField.scrollV = _traceField.maxScrollV;
			}else if(!b){
				_atBottom = true;
				updateBottom();
			}
			updateMenu();
		}
		private function updateBottom():void{
			var lines:Array = new Array();
			var linesLeft:int = Math.round(_traceField.height/style.traceFontSize);
			var maxchars:int = Math.round(_traceField.width*5/style.traceFontSize);
			
			var line:Log = console.logs.last;
			while(line){
				if(lineShouldShow(line)){
					var numlines:int = Math.ceil(line.text.length/ maxchars);
					if(line.html || linesLeft >= numlines ){
						lines.push(makeLine(line));
					}else{
						line = line.clone();
						line.text = line.text.substring(Math.max(0,line.text.length-(maxchars*linesLeft)));
						lines.push(makeLine(line));
						break;
					}
					linesLeft-=numlines;
					if(linesLeft<=0){
						break;
					}
				}
				line = line.prev;
			}
			_lockScrollUpdate = true;
			_traceField.htmlText = lines.reverse().join("");
			_traceField.scrollV = _traceField.maxScrollV;
			_lockScrollUpdate = false;
			updateScroller();
		}
		private function lineShouldShow(line:Log):Boolean{
			return (
				(
					_viewingChannels.length == 0
			 		|| _viewingChannels.indexOf(line.ch)>=0 
			 		|| (_filterText && _viewingChannels.indexOf(Console.FILTER_CHANNEL) >= 0 && line.text.toLowerCase().indexOf(_filterText)>=0 )
			 		|| (_filterRegExp && _viewingChannels.indexOf(Console.FILTER_CHANNEL)>=0 && line.text.search(_filterRegExp)>=0 )
			 	) 
			 	&& ( _priority <= 0 || line.priority >= _priority)
			);
		}
		public function get reportChannel():String{
			return _viewingChannels.length == 1?_viewingChannels[0]:Console.CONSOLE_CHANNEL;
		}
		public function get viewingChannels():Array{
			return _viewingChannels;
		}
		public function set viewingChannels(a:Array):void{
			if(_viewingChannels[0] == LogReferences.INSPECTING_CHANNEL && (!a || a[0] != _viewingChannels[0])){
				console.links.exitFocus();
			}
			_viewingChannels.splice(0);
			if(a.indexOf(Console.GLOBAL_CHANNEL) < 0 && a.indexOf(null) < 0){
				for each(var ch:String in a) _viewingChannels.push(ch);
			}
			updateToBottom();
			console.panels.updateMenu();
		}
		//
		private function setFilterText(str:String = ""):void{
			if(str){
				_filterRegExp = null;
				_filterText = LogReferences.EscHTML(str.toLowerCase());
				startFilter();
			}else{
				endFilter();
			}
		}
		private function setFilterRegExp(expstr:String = ""):void{
			if(expstr){
				_filterText = null;
				_filterRegExp = new RegExp(LogReferences.EscHTML(expstr), "gi");
				startFilter();
			}else{
				endFilter();
			}
		}
		private function startFilter():void{
			console.clear(Console.FILTER_CHANNEL);
			console.logs.addChannel(Console.FILTER_CHANNEL);
			viewingChannels = [Console.FILTER_CHANNEL];
		}
		private function endFilter():void{
			_filterRegExp = null;
			_filterText = null;
			if(_viewingChannels.length == 1 && _viewingChannels[0] == Console.FILTER_CHANNEL){
				viewingChannels = [Console.GLOBAL_CHANNEL];
			}
		}
		private function makeLine(line:Log):String{
			var str:String = "";
			var txt:String = line.text;
			if(line.ch != Console.DEFAULT_CHANNEL && (_viewingChannels.length == 0 || _viewingChannels.length>1)){
				txt = "[<a href=\"event:channel_"+line.ch+"\">"+line.ch+"</a>] "+txt;
			}
			var index:int;
			if(_filterRegExp){
				// need to look into every match to make sure there no half way HTML tags and not inside the HTML tags it self in the match.
				_filterRegExp.lastIndex = 0;
				var result:Object = _filterRegExp.exec(txt);
				while (result != null) {
					index = result.index;
					var match:String = result[0];
					if(match.search("<|>")>=0){
						_filterRegExp.lastIndex -= match.length-match.search("<|>");
					}else if(txt.lastIndexOf("<", index)<=txt.lastIndexOf(">", index)){
						txt = txt.substring(0, index)+"<u>"+txt.substring(index, index+match.length)+"</u>"+txt.substring(index+match.length);
						_filterRegExp.lastIndex+=7; // need to add to satisfy the fact that we added <u> and </u>
					}
					result = _filterRegExp.exec(txt);
				}
			}else if(_filterText){
				// could have been simple if txt.replace replaces every match.
				var lowercase:String = txt.toLowerCase();
				index = lowercase.lastIndexOf(_filterText);
				while(index>=0){
					txt = txt.substring(0, index)+"<u>"+txt.substring(index, index+_filterText.length)+"</u>"+txt.substring(index+_filterText.length);
					index = lowercase.lastIndexOf(_filterText, index-2);
				}
			}
			var ptag:String = "p"+line.priority;
			str += "<p><"+ptag+">" + txt + "</"+ptag+"></p>";
			return str;
		}
		//
		// START OF SCROLL BAR STUFF
		//
		private function onTraceScroll(e:Event = null):void{
			if(_lockScrollUpdate) return;
			var atbottom:Boolean = _traceField.scrollV >= _traceField.maxScrollV;
			if(!console.paused && _atBottom !=atbottom){
				var diff:int = _traceField.maxScrollV-_traceField.scrollV;
				_selectionStart = _traceField.text.length-_traceField.selectionBeginIndex;
				_selectionEnd = _traceField.text.length-_traceField.selectionEndIndex;
				_atBottom = atbottom;
				_updateTraces();
				_traceField.scrollV = _traceField.maxScrollV-diff;
			}
			updateScroller();
		}
		private function updateScroller():void{
			if(_traceField.maxScrollV <= 1){
				_scroll.visible = false;
			}else{
				_scroll.visible = true;
				if(_atBottom) {
					scrollPercent = 1;
				}else{
					scrollPercent = (_traceField.scrollV-1)/(_traceField.maxScrollV-1);
				}
			}
		}
		private function onScrollbarDown(e:MouseEvent):void{
			if((_scroller.visible && _scroller.mouseY>0) || (!_scroller.visible && _scroll.mouseY>_scrollHeight/2)) {
				_scrolldir = 3;
			}else {
				_scrolldir = -3;
			}
			_traceField.scrollV += _scrolldir;
			_scrolldelay = 0;
			addEventListener(Event.ENTER_FRAME, onScrollBarFrame, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onScrollBarUp, false, 0, true);
		}
		private function onScrollBarFrame(e:Event):void{
			_scrolldelay++;
			if(_scrolldelay>10){
				_scrolldelay = 9;
				if((_scrolldir<0 && _scroller.y>_scroll.mouseY)||(_scrolldir>0 && _scroller.y+_scroller.height<_scroll.mouseY)){
					_traceField.scrollV += _scrolldir;
				}
			}
		}
		private function onScrollBarUp(e:Event):void{
			removeEventListener(Event.ENTER_FRAME, onScrollBarFrame);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onScrollBarUp);
		}
		//
		//
		private function get scrollPercent():Number{
			return (_scroller.y-5)/(_scrollHeight-40);
		}
		private function set scrollPercent(per:Number):void{
			_scroller.y = 5+((_scrollHeight-40)*per);
		}
		private function onScrollerDown(e:MouseEvent):void{
			_scrolling = true;
			
			if(!console.paused && _atBottom){
				_atBottom = false;
				var p:Number = scrollPercent;
				_updateTraces();
				scrollPercent = p;
			}
			
			_scroller.startDrag(false, new Rectangle(0,5, 0, (_scrollHeight-40)));
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onScrollerMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onScrollerUp, false, 0, true);
			e.stopPropagation();
		}
		private function onScrollerMove(e:MouseEvent):void{
			_lockScrollUpdate = true;
			_traceField.scrollV = Math.round((scrollPercent*(_traceField.maxScrollV-1))+1);
			_lockScrollUpdate = false;
		}
		private function onScrollerUp(e:MouseEvent):void{
			_scroller.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onScrollerMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onScrollerUp);
			_scrolling = false;
			onTraceScroll();
		}
		//
		// END OF SCROLL BAR STUFF
		//
		override public function set width(n:Number):void{
			_lockScrollUpdate = true;
			super.width = n;
			_traceField.width = n-4;
			txtField.width = n-6;
			_cmdField.width = width-15-_cmdField.x;
			_cmdBG.width = n;
			
			_bottomLine.graphics.clear();
			_bottomLine.graphics.lineStyle(1, style.controlColor);
			_bottomLine.graphics.moveTo(10, -1);
			_bottomLine.graphics.lineTo(n-10, -1);
			_scroll.x = n;
			_atBottom = true;
			updateCLSize();
			_needUpdateMenu = true;
			_needUpdateTrace = true;
			_lockScrollUpdate = false;
		}
		override public function set height(n:Number):void{
			_lockScrollUpdate = true;
			var fsize:int = style.menuFontSize;
			var msize:Number = fsize+6+style.traceFontSize;
			if(height != n){
				_mini = n < (_cmdField.visible?(msize+fsize+4):msize);
			}
			super.height = n;
			var mini:Boolean = _mini || !style.topMenu;
			_traceField.y = mini?0:fsize;
			_traceField.height = n-(_cmdField.visible?(fsize+4):0)-(mini?0:fsize);
			var cmdy:Number = n-(fsize+6);
			_cmdField.y = cmdy;
			_cmdPrefx.y = cmdy;
			_hintField.y = _cmdField.y-_hintField.height;
			_cmdBG.y = cmdy;
			_bottomLine.y = _cmdField.visible?cmdy:n;
			//
			_scroll.y = mini?6:fsize+4;
			_scrollHeight = (_bottomLine.y-(_cmdField.visible?0:10))-_scroll.y;
			_scroller.visible = _scrollHeight>40;
			_scroll.graphics.clear();
			if(_scrollHeight>=10){
				_scroll.graphics.beginFill(style.controlColor, 0.7);
				_scroll.graphics.drawRect(-5, 0, 5, 5);
				_scroll.graphics.drawRect(-5, _scrollHeight-5, 5, 5);
				_scroll.graphics.beginFill(style.controlColor, 0.25);
				_scroll.graphics.drawRect(-5, 5, 5, _scrollHeight-10);
				_scroll.graphics.beginFill(0, 0);
				_scroll.graphics.drawRect(-10, 10, 10, _scrollHeight-10);
				_scroll.graphics.endFill();
			}
			//
			_atBottom = true;
			_needUpdateTrace = true;
			_lockScrollUpdate = false;
		}
		//
		//
		//
		public function updateMenu(instant:Boolean = false):void{
			if(instant){
				_updateMenu();
			}else{
				_needUpdateMenu = true;
			}
		}
		private function _updateMenu():void{
			var str:String = "<r><w>";
			if(_mini || !style.topMenu){
				str += "<menu><b> <a href=\"event:show\">‹</a>";
			}else {
				if(!console.panels.channelsPanel){
					str += getChannelsLink(true);
				}
				str += "<menu> <b>";
				
				var extra:Boolean;
				for (var X:String in _extraMenus){
					str += "<a href=\"event:external_"+X+"\">"+X+"</a> ";
					extra = true;
				}
				if(extra) str += "¦ ";
				
				str += doActive("<a href=\"event:fps\">F</a>", console.fpsMonitor>0);
				str += doActive(" <a href=\"event:mm\">M</a>", console.memoryMonitor>0);
				
				str += doActive(" <a href=\"event:command\">CL</a>", commandLine);
				
				if(console.remoter.remoting != Remoting.RECIEVER){
					if(config.displayRollerEnabled)
					str += doActive(" <a href=\"event:roller\">Ro</a>", console.displayRoller);
					str += doActive(" <a href=\"event:ruler\">RL</a>", console.panels.rulerActive);
				}
				str += " ¦</b>";
				str += " <a href=\"event:copy\">Cc</a>";
				str += " <a href=\"event:priority\">P"+_priority+"</a>";
				str += doActive(" <a href=\"event:pause\">P</a>", console.paused);
				str += " <a href=\"event:clear\">C</a> <a href=\"event:close\">X</a> <a href=\"event:hide\">›</a>";
			}
			str += " </b></menu></w></r>";
			txtField.htmlText = str;
			txtField.scrollH = txtField.maxScrollH;
		}
		public function getChannelsLink(limited:Boolean = false):String{
			var str:String = "<chs>";
			var channels:Array = console.logs.getChannels();
			var len:int = channels.length;
			if(limited && len>style.maxChannelsInMenu) len = style.maxChannelsInMenu;
			for(var i:int = 0; i<len;  i++){
				var channel:String = channels[i];
				var channelTxt:String = ((i == 0 && _viewingChannels.length == 0) || _viewingChannels.indexOf(channel)>=0) ? "<ch><b>"+channel+"</b></ch>" : channel;
				str += "<a href=\"event:channel_"+channel+"\">["+channelTxt+"]</a> ";
			}
			if(limited){
				str += "<ch><a href=\"event:channels\"><b>"+(channels.length>len?"...":"")+"</b>^^ </a></ch>";
			}
			str += "</chs> ";
			return str;
		}
		private function doActive(str:String, b:Boolean):String{
			if(b) return "<hi>"+str+"</hi>";
			return str;
		}
		public function onMenuRollOver(e:TextEvent, src:AbstractPanel = null):void{
			if(src==null) src = this;
			var txt:String = e.text?e.text.replace("event:",""):"";
			if(txt == "channel_"+Console.GLOBAL_CHANNEL){
				txt = "View all channels";
			}else if(txt == "channel_"+Console.DEFAULT_CHANNEL) {
				txt = "Default channel::Logs with no channel";
			}else if(txt == "channel_"+ Console.CONSOLE_CHANNEL) {
				txt = "Console's channel::Logs generated from Console";
			}else if(txt == "channel_"+ Console.FILTER_CHANNEL) {
				txt = _filterRegExp?String(_filterRegExp):_filterText;
				txt = "Filtering channel"+"::*"+txt+"*";
			}else if(txt == "channel_"+LogReferences.INSPECTING_CHANNEL) {
				txt = "Inspecting channel";
			}else if(txt.indexOf("channel_")==0) {
				txt = "Change channel::shift click to select multiple. ctrl click to invert select.";
			}else if(txt == "pause"){
				if(console.paused) txt = "Resume updates";
				else txt = "Pause updates";
			}else if(txt == "close" && src == this){
				txt = "Close::Type password to show again";
			}else if(txt.indexOf("external_")==0){
				var menu:Array = _extraMenus[txt.substring(9)];
				if(menu) txt = menu[2];
			}else{
				var obj:Object = {
					fps:"Frames Per Second",
					mm:"Memory Monitor",
					roller:"Display Roller::Map the display list under your mouse",
					ruler:"Screen Ruler::Measure the distance and angle between two points on screen.",
					command:"Command Line",
					copy:"Copy to clipboard",
					clear:"Clear log",
					priority:"Priority filter::shift click to reverse. skips unused priorites.",
					channels:"Expand channels",
					close:"Close"
					};
				txt = obj[txt];
			}
			console.panels.tooltip(txt, src);
		}
		private function linkHandler(e:TextEvent):void{
			txtField.setSelection(0, 0);
			stopDrag();
			var t:String = e.text;
			if(t == "pause"){
				if(console.paused){
					console.paused = false;
				}else{
					console.paused = true;
				}
				console.panels.tooltip(null);
			}else if(t == "hide"){
				console.panels.tooltip();
				_mini = true;
				console.config.style.topMenu = false;
				height = height;
				updateMenu();
			}else if(t == "show"){
				console.panels.tooltip();
				_mini = false;
				console.config.style.topMenu = true;
				height = height;
				updateMenu();
			}else if(t == "close"){
				console.panels.tooltip();
				visible = false;
				dispatchEvent(new Event(Event.CLOSE));
			}else if(t == "channels"){
				console.panels.channelsPanel = !console.panels.channelsPanel;
			}else if(t == "fps"){
				console.fpsMonitor = !console.fpsMonitor;
			}else if(t == "priority"){
				incPriority(_shift);
			}else if(t == "mm"){
				console.memoryMonitor = !console.memoryMonitor;
			}else if(t == "roller"){
				console.displayRoller = !console.displayRoller;
			}else if(t == "ruler"){
				console.panels.tooltip();
				console.panels.startRuler();
			}else if(t == "command"){
				commandLine = !commandLine;
			}else if(t == "copy") {
				System.setClipboard(console.getAllLog());
				console.report("Copied log to clipboard.", -1);
			}else if(t == "clear"){
				console.clear();
			}else if(t == "settings"){
				console.report("A new window should open in browser. If not, try searching for 'Flash Player Global Security Settings panel' online :)", -1);
				Security.showSettings(SecurityPanel.SETTINGS_MANAGER);
			}else if(t == "remote"){
				console.remoter.remoting = Remoting.RECIEVER;
			}else if(t.indexOf("ref")==0){
				console.links.handleRefEvent(t);
			}else if(t.indexOf("channel_")==0){
				onChannelPressed(t.substring(8));
			}else if(t.indexOf("cl_")==0){
				var ind:int = t.indexOf("_", 3);
				console.cl.handleScopeEvent(uint(t.substring(3, ind<0?t.length:ind)));
				if(ind>=0){
					_cmdField.text = t.substring(ind+1);
				}
			}else if(t.indexOf("external_")==0){
				var menu:Array = _extraMenus[t.substring(9)];
				if(menu) menu[0].apply(null, menu[1]);
			}
			txtField.setSelection(0, 0);
			e.stopPropagation();
		}
		public function onChannelPressed(chn:String):void{
			var current:Array = _viewingChannels.concat();
			if(_ctrl && chn != Console.GLOBAL_CHANNEL){
				var channels:Array = console.logs.getChannels();
				var i:int = channels.indexOf(chn);
				if(i >= 0){
					channels.splice(i, 1);
					channels.splice(0, 1);
				}
				viewingChannels = channels;
			}
			else if(_shift && chn != Console.GLOBAL_CHANNEL && current[0] != LogReferences.INSPECTING_CHANNEL){
				var ind:int = current.indexOf(chn);
				if(ind>=0){
					current.splice(ind,1);
					if(current.length == 0){
						current.push(Console.GLOBAL_CHANNEL);
					}
				}else{
					current.push(chn);
				}
				viewingChannels = current;
			}else{
				console.setViewingChannels(chn);
			}
		}
		public function set priority(p:int):void{
			_priority = p;
			updateToBottom();
			updateMenu();
		}
		public function get priority():int{
			return _priority;
		}
		//
		private function incPriority(down:Boolean):void{
			var top:uint = 10;
			var bottom:uint;
			var line:Log = console.logs.last;
			var p:int = _priority;
			_priority = 0;
			var i:uint = 32000; // just for crash safety, it wont look more than 32000 lines.
			while(line && i>0){
				i--;
				if(lineShouldShow(line)){
					if(line.priority > p && top>line.priority) top = line.priority;
					if(line.priority < p && bottom<line.priority) bottom = line.priority;
				}
				line = line.prev;
			}
			if(down){
				if(bottom == p) p = 10;
				else p = bottom;
			}else{
				if(top == p) p = 0;
				else p = top;
			}
			priority = p;
		}
		//
		// COMMAND LINE
		//
		private function clearCommandLineHistory(...args:Array):void
		{
			_cmdsInd = -1;
			console.updateSO();
			_cmdsHistory = new Array();
		}
		private function commandKeyDown(e:KeyboardEvent):void{
			e.stopPropagation();
		}
		private function commandKeyUp(e:KeyboardEvent):void{
			if( e.keyCode == Keyboard.ENTER){
				updateToBottom();
				setHints();
				if(_enteringLogin){
					console.remoter.login(_cmdField.text);
					_cmdField.text = "";
					requestLogin(false);
				}else{
					var txt:String = _cmdField.text;
					if(txt.length > 2){
						var i:int = _cmdsHistory.indexOf(txt);
						while(i>=0){
							_cmdsHistory.splice(i,1);
							i = _cmdsHistory.indexOf(txt);
						}
						_cmdsHistory.unshift(txt);
						_cmdsInd = -1;
						// maximum 20 commands history
						if(_cmdsHistory.length>20){
							_cmdsHistory.splice(20);
						}
						console.updateSO(CL_HISTORY);
					}
					_cmdField.text = "";
					console.cl.run(txt);
				}
			}else if( e.keyCode == Keyboard.ESCAPE){
				if(stage) stage.focus = null;
			}else if( e.keyCode == Keyboard.UP){
				setHints();
				// if its back key for first time, store the current key
				if(_cmdField.text && _cmdsInd<0){
					_cmdsHistory.unshift(_cmdField.text);
					_cmdsInd++;
				}
				if(_cmdsInd<(_cmdsHistory.length-1)){
					_cmdsInd++;
					_cmdField.text = _cmdsHistory[_cmdsInd];
					_cmdField.setSelection(_cmdField.text.length, _cmdField.text.length);
				}else{
					_cmdsInd = _cmdsHistory.length;
					_cmdField.text = "";
				}
			}else if( e.keyCode == Keyboard.DOWN){
				setHints();
				if(_cmdsInd>0){
					_cmdsInd--;
					_cmdField.text = _cmdsHistory[_cmdsInd];
					_cmdField.setSelection(_cmdField.text.length, _cmdField.text.length);
				}else{
					_cmdsInd = -1;
					_cmdField.text = "";
				}
			}
			else if(e.keyCode == Keyboard.SPACE){
				if(_hint) 
				{
					_cmdField.text = _hint;
					_cmdField.setSelection(_cmdField.text.length, _cmdField.text.length);
					setHints();
				}
			}
			else if(!_enteringLogin) updateCmdHint();
			e.stopPropagation();
		}
		private function updateCmdHint(e:Event = null):void{
			var hints:Array;
			var str:String = _cmdField.text;
			if(str && console.remoter.remoting != Remoting.RECIEVER){
				hints = console.cl.getHintsFor(str);
				if(hints.length>3){
					hints.splice(3);
					hints.push("...");
				}
			}
			setHints(hints);
		}
		private function onCmdFocusOut(e:Event):void{
			setHints();
		}
		private function setHints(a:Array = null):void{
			if(a && a.length)
			{
				_hint = a[0];
				a = a.reverse();
				_hintField.text = a.join("\n");
				_hintField.visible = true;
				var r:Rectangle = _cmdField.getCharBoundaries(_cmdField.text.length-1);
				if(!r) r = new Rectangle();
				_hintField.x = _cmdField.x + r.x + r.width+20;
				_hintField.y = height-_hintField.height;
			}else{
				_hintField.visible = false;
				_hint = null;
			}
		}
		public function updateCLScope(str:String):void{
			if(_enteringLogin) {
				_enteringLogin = false;
				requestLogin(false);
			}
			_cmdPrefx.autoSize = TextFieldAutoSize.LEFT;
			_cmdPrefx.text = str;
			updateCLSize();
		}
		private function updateCLSize():void{
			var w:Number = width-48;
			if(_cmdPrefx.width > 120 || _cmdPrefx.width > w){
				_cmdPrefx.autoSize = TextFieldAutoSize.NONE;
				_cmdPrefx.width = w>120?120:w;
				_cmdPrefx.scrollH = _cmdPrefx.maxScrollH;
			}
			_cmdField.x = _cmdPrefx.width+2;
			_cmdField.width = width-15-_cmdField.x;
			_hintField.x = _cmdField.x;
		}
		public function set commandLine(b:Boolean):void{
			if(b){
				_cmdField.visible = true;
				_cmdPrefx.visible = true;
				_cmdBG.visible = true;
			}else{
				_cmdField.visible = false;
				_cmdPrefx.visible = false;
				_cmdBG.visible = false;
			}
			_needUpdateMenu = true;
			this.height = height;
		}
		public function get commandLine():Boolean{
			return _cmdField.visible;
		}
	}
}