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
package com.junkbyte.console 
{
	import com.junkbyte.console.core.CommandLine;
	import com.junkbyte.console.core.ConsoleTools;
	import com.junkbyte.console.core.Graphing;
	import com.junkbyte.console.core.KeyBinder;
	import com.junkbyte.console.core.LogReferences;
	import com.junkbyte.console.core.Logs;
	import com.junkbyte.console.core.MemoryMonitor;
	import com.junkbyte.console.core.Remoting;
	import com.junkbyte.console.view.PanelsManager;
	import com.junkbyte.console.view.RollerPanel;
	import com.junkbyte.console.vos.Log;

	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	/**
	 * Console is the main class. 
	 * Please see com.junkbyte.console.Cc for documentation as it shares the same properties and methods structure.
	 * @see http://code.google.com/p/flash-console/
	 * @see com.junkbyte.console.Cc
	 */
	public class Console extends Sprite {

		public static const VERSION:Number = 2.5;
		public static const VERSION_STAGE:String = "beta5";
		public static const BUILD:int = 559;
		public static const BUILD_DATE:String = "2010/12/12 13:37";
		//
		public static const LOG:uint = 1;
		public static const INFO:uint = 3;
		public static const DEBUG:uint = 6;
		public static const WARN:uint = 8;
		public static const ERROR:uint = 9;
		public static const FATAL:uint = 10;
		//
		public static const GLOBAL_CHANNEL:String = " * ";
		public static const DEFAULT_CHANNEL:String = "-";
		public static const CONSOLE_CHANNEL:String = "C";
		public static const FILTER_CHANNEL:String = "~";
		//
		private var _config:ConsoleConfig;
		private var _panels:PanelsManager;
		private var _cl:CommandLine;
		private var _kb:KeyBinder;
		private var _links:LogReferences;
		private var _mm:MemoryMonitor;
		private var _graphing:Graphing;
		private var _remoter:Remoting;
		private var _tools:ConsoleTools;
		//
		private var _topTries:int = 50;
		private var _paused:Boolean;
		private var _rollerKey:KeyBind;
		private var _logs:Logs;
		private var _lineAdded:Boolean;
		
		private var _so:SharedObject;
		private var _soData:Object = {};
		
		/**
		 * Console is the main class. However please use Cc for singleton Console adapter.
		 * Using Console through Cc will also make sure you can remove console in a later date
		 * by simply removing Cc.start() or Cc.startOnStage()
	 	 * See com.junkbyte.console.Cc for documentation as it shares the same properties and methods structure.
		 * 
		 * @see com.junkbyte.console.Cc
		 * @see http://code.google.com/p/flash-console/
		 */
		public function Console(pass:String = "", config:ConsoleConfig = null) {
			name = "Console";
			tabChildren = false; // Tabbing is not supported
			_config = config?config:new ConsoleConfig();
			//
			_remoter = new Remoting(this, pass);
			_logs = new Logs(this);
			_links = new LogReferences(this);
			_cl = new CommandLine(this);
			_tools =  new ConsoleTools(this);
			_graphing = new Graphing(this);
			_mm = new MemoryMonitor(this);
			_kb = new KeyBinder(this, pass);
			
			if(config.sharedObjectName){
				try{
					_so = SharedObject.getLocal(config.sharedObjectName, config.sharedObjectPath);
					_soData = _so.data;
				}catch(e:Error){
					
				}
			}
			
			_config.style.updateStyleSheet();
			_panels = new PanelsManager(this);
			
			
			report("<b>Console v"+VERSION+VERSION_STAGE+" b"+BUILD+". Happy coding!</b>", -2);
			addEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
			if(pass) visible = false;
			// must have enterFrame here because user can start without a parent display and use remoting.
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		private function stageAddedHandle(e:Event=null):void{
			if(_cl.base == null) _cl.base = parent;
			if(loaderInfo){
				listenUncaughtErrors(loaderInfo);
			}
			removeEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
			addEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle);
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _kb.keyDownHandler, false, 0, true);
		}
		private function stageRemovedHandle(e:Event=null):void{
			_cl.base = null;
			removeEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle);
			addEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, _kb.keyDownHandler);
		}
		private function onStageMouseLeave(e:Event):void{
			_panels.tooltip(null);
		}
		// requires flash player target to be 10.1
		public function listenUncaughtErrors(loaderinfo:LoaderInfo):void {
			try{
				var uncaughtErrorEvents:IEventDispatcher = loaderinfo["uncaughtErrorEvents"];
				if(uncaughtErrorEvents){
					uncaughtErrorEvents.addEventListener("uncaughtError", uncaughtErrorHandle, false, 0, true);
				}
			}catch(err:Error){
				// seems uncaughtErrorEvents is not avaviable on this player/target, which is fine.
			}
		}
		private function uncaughtErrorHandle(e:Event):void{
			var error:* = e.hasOwnProperty("error")?e["error"]:e; // for flash 9 compatibility
			var str:String;
			if (error is Error){
				str = _links.makeString(error);
			}else if (error is ErrorEvent){
				str = ErrorEvent(error).text;
			}
			if(!str){
				str = String(error);
			}
			report(str, FATAL, false);
		}
		
		public function addGraph(n:String, obj:Object, prop:String, col:Number = -1, key:String = null, rect:Rectangle = null, inverse:Boolean = false):void{
			_graphing.add(n,obj,prop,col,key,rect,inverse);
		}
		public function fixGraphRange(n:String, min:Number = NaN, max:Number = NaN):void{
			_graphing.fixRange(n, min, max);
		}
		public function removeGraph(n:String, obj:Object = null, prop:String = null):void{
			_graphing.remove(n, obj, prop);
		}
		//
		// WARNING: key binding hard references the functoin and arguments.
		// This should only be used for development purposes only.
		//
		public function bindKey(key:KeyBind, fun:Function ,args:Array = null):void{
			if(key) _kb.bindKey(key, fun, args);
		}
		//
		// WARNING: Add menu hard references the functoin and arguments.
		//
		public function addMenu(key:String, f:Function, args:Array = null, rollover:String = null):void{
			panels.mainPanel.addMenu(key, f, args, rollover);
		}
		//
		// Panel settings
		// basically passing through to panels manager to save lines
		//
		public function get displayRoller():Boolean{
			return _panels.displayRoller;
		}
		public function set displayRoller(b:Boolean):void{
			_panels.displayRoller = b;
		}
		public function setRollerCaptureKey(char:String, shift:Boolean = false, ctrl:Boolean = false, alt:Boolean = false):void{
			if(_rollerKey){
				bindKey(_rollerKey, null);
				_rollerKey = null;
			}
			if(char && char.length==1) {
				_rollerKey = new KeyBind(char, shift, ctrl, alt);
				bindKey(_rollerKey, onRollerCaptureKey);
			}
		}
		public function get rollerCaptureKey():KeyBind{
			return _rollerKey;
		}
		private function onRollerCaptureKey():void{
			if(displayRoller){
				report("Display Roller Capture:<br/>"+RollerPanel(_panels.getPanel(RollerPanel.NAME)).getMapString(true), -1);
			}
		}
		//
		public function get fpsMonitor():Boolean{
			return _graphing.fpsMonitor;
		}
		public function set fpsMonitor(b:Boolean):void{
			_graphing.fpsMonitor = b;
		}
		//
		public function get memoryMonitor():Boolean{
			return _graphing.memoryMonitor;
		}
		public function set memoryMonitor(b:Boolean):void{
			_graphing.memoryMonitor = b;
		}
		
		//
		public function watch(o:Object,n:String = null):String{
			return _mm.watch(o,n);
		}
		public function unwatch(n:String):void{
			_mm.unwatch(n);
		}
		public function gc():void{
			_mm.gc();
		}
		public function store(n:String, obj:Object, strong:Boolean = false):void{
			_cl.store(n, obj, strong);
		}
		public function map(base:DisplayObjectContainer, maxstep:uint = 0):void{
			_tools.map(base, maxstep, DEFAULT_CHANNEL);
		}
		public function mapch(channel:*, base:DisplayObjectContainer, maxstep:uint = 0):void{
			_tools.map(base, maxstep, MakeChannelName(channel));
		}
		public function inspect(obj:Object, detail:Boolean = true):void{
			_links.inspect(obj, detail, DEFAULT_CHANNEL);
		}
		public function inspectch(channel:*, obj:Object, detail:Boolean = true):void{
			_links.inspect(obj,detail, MakeChannelName(channel));
		}
		public function explode(obj:Object, depth:int = 3):void{
			addLine(new Array(_tools.explode(obj, depth)), 1, null, false, true);
		}
		public function explodech(channel:*, obj:Object, depth:int = 3):void{
			addLine(new Array(_tools.explode(obj, depth)), 1, MakeChannelName(channel), false, true);
		}
		public function get paused():Boolean{
			return _paused;
		}
		public function set paused(newV:Boolean):void{
			if(_paused == newV) return;
			if(newV) report("Paused", 10);
			else report("Resumed", -1);
			_paused = newV;
			_panels.mainPanel.setPaused(newV);
		}
		//
		//
		//
		override public function get width():Number{
			return _panels.mainPanel.width;
		}
		override public function set width(newW:Number):void{
			_panels.mainPanel.width = newW;
		}
		override public function set height(newW:Number):void{
			_panels.mainPanel.height = newW;
		}
		override public function get height():Number{
			return _panels.mainPanel.height;
		}
		override public function get x():Number{
			return _panels.mainPanel.x;
		}
		override public function set x(newW:Number):void{
			_panels.mainPanel.x = newW;
		}
		override public function set y(newW:Number):void{
			_panels.mainPanel.y = newW;
		}
		override public function get y():Number{
			return _panels.mainPanel.y;
		}
		//
		//
		//
		private function _onEnterFrame(e:Event):void{
			_logs.tick();
			_links.tick();
			_mm.update();
			var graphsList:Array;
			if(remoter.remoting != Remoting.RECIEVER)
			{
			 	graphsList = _graphing.update(stage?stage.frameRate:0);
			}
			_remoter.update(graphsList);
			
			// VIEW UPDATES ONLY
			if(visible && parent){
				if(config.alwaysOnTop && parent.getChildAt(parent.numChildren-1) != this && _topTries>0){
					_topTries--;
					parent.addChild(this);
					//if(!config.quiet) 
					report("Moved console on top (alwaysOnTop enabled), "+_topTries+" attempts left.",-1);
				}
				_panels.update(_paused, _lineAdded);
				if(graphsList) _panels.updateGraphs(graphsList, !_paused); 
				_lineAdded = false;
			}
		}
		//
		// REMOTING
		//
		public function get remoting():Boolean{
			return _remoter.remoting == Remoting.SENDER;
		}
		public function set remoting(b:Boolean):void{
			_remoter.remoting = b?Remoting.SENDER:Remoting.NONE;
		}
		public function set remotingPassword(str:String):void{
			_remoter.remotingPassword = str;
		}
		//
		//
		//
		public function setViewingChannels(...args:Array):void{
			var a:Array = new Array();
			for each(var item:Object in args) a.push(MakeChannelName(item));
			_panels.mainPanel.viewingChannels = a;
		}
		public function report(obj:*, priority:int = 0, skipSafe:Boolean = true, ch:String = null):void{
			if(!ch) ch = _panels.mainPanel.reportChannel;
			addLine([obj], priority, ch, false, skipSafe);
		}
		public function addLine(lineParts:Array, priority:int = 0,channel:String = null,isRepeating:Boolean = false, html:Boolean = false, stacks:int = -1):void{
			var txt:String = "";
			var len:int = lineParts.length;
			for(var i:int = 0; i < len; i++){
				txt += (i?" ":"")+_links.makeString(lineParts[i], null, html);
			}
			
			if(priority >= _config.autoStackPriority && stacks<0) stacks = _config.defaultStackDepth;
			
			if(!channel || channel == GLOBAL_CHANNEL) channel = Console.DEFAULT_CHANNEL;

			if(!html && stacks>0){
				txt += _tools.getStack(stacks, priority);
			}
			var line:Log = new Log(txt, channel, priority, isRepeating, html);
			
			var cantrace:Boolean = _logs.add(line, isRepeating);
			if( _config.tracing && cantrace && _config.traceCall != null){
				_config.traceCall(channel, line.plainText(), priority);
			}
			
			_lineAdded = true;
			_remoter.queueLog(line);
		}
		//
		// COMMAND LINE
		//
		public function set commandLine(b:Boolean):void{
			_panels.mainPanel.commandLine = b;
		}
		public function get commandLine ():Boolean{
			return _panels.mainPanel.commandLine;
		}
		public function addSlashCommand(n:String, callback:Function, desc:String = "", allow:Boolean = true):void{
			_cl.addSlashCommand(n, callback, desc, allow);
		}
		//
		// LOGGING
		//
		public function add(newLine:*, priority:int = 2, isRepeating:Boolean = false):void{
			addLine(new Array(newLine), priority, DEFAULT_CHANNEL, isRepeating);
		}
		public function stack(newLine:*, depth:int = -1, priority:int = 5):void{
			addLine(new Array(newLine), priority, DEFAULT_CHANNEL, false, false, depth>=0?depth:_config.defaultStackDepth);
		}
		public function stackch(ch:String, newLine:*, depth:int = -1, priority:int = 5):void{
			addLine(new Array(newLine), priority, ch, false, false, depth>=0?depth:_config.defaultStackDepth);
		}
		public function log(...args):void{
			addLine(args, LOG);
		}
		public function info(...args):void{
			addLine(args, INFO);
		}
		public function debug(...args):void{
			addLine(args, DEBUG);
		}
		public function warn(...args):void{
			addLine(args, WARN);
		}
		public function error(...args):void{
			addLine(args, ERROR);
		}
		public function fatal(...args):void{
			addLine(args, FATAL);
		}
		public function ch(channel:*, newLine:*, priority:Number = 2, isRepeating:Boolean = false):void{
			addLine(new Array(newLine), priority, MakeChannelName(channel), isRepeating);
		}
		public function logch(channel:*, ...args):void{
			addLine(args, LOG, MakeChannelName(channel));
		}
		public function infoch(channel:*, ...args):void{
			addLine(args, INFO, MakeChannelName(channel));
		}
		public function debugch(channel:*, ...args):void{
			addLine(args, DEBUG, MakeChannelName(channel));
		}
		public function warnch(channel:*, ...args):void{
			addLine(args, WARN, MakeChannelName(channel));
		}
		public function errorch(channel:*, ...args):void{
			addLine(args, ERROR, MakeChannelName(channel));
		}
		public function fatalch(channel:*, ...args):void{
			addLine(args, FATAL, MakeChannelName(channel));
		}
		public function addCh(channel:*, lineParts:Array, priority:int = 2, isRepeating:Boolean = false):void{
			addLine(lineParts, priority, MakeChannelName(channel), isRepeating);
		}
		//
		//
		//
		public function clear(channel:String = null):void{
			_logs.clear(channel);
			if(!_paused) _panels.mainPanel.updateToBottom();
			_panels.updateMenu();
		}
		public function getAllLog(splitter:String = "\r\n"):String{
			return _logs.getLogsAsString(splitter);
		}
		public function get config():ConsoleConfig{return _config;}
		public function get panels():PanelsManager{return _panels;}
		public function get cl():CommandLine{return _cl;}
		public function get remoter():Remoting{return _remoter;}
		public function get graphing():Graphing{return _graphing;}
		public function get links():LogReferences{return _links;}
		public function get logs():Logs{return _logs;}
		public function get mapper():ConsoleTools{return _tools;}
		
		public function get so():Object{return _soData;}
		public function updateSO(key:String = null):void{
			if(_so) {
				if(key) _so.setDirty(key);
				else _so.clear();
			}
		}
		//
		//
		//
		public static function MakeChannelName(obj:*):String{
			if(obj is String) return obj as String;
			//else if(obj is ConsoleChannel) return ConsoleChannel(obj).name;
			else if(obj) return LogReferences.ShortClassName(obj);
			else return DEFAULT_CHANNEL;
		}
	}
}