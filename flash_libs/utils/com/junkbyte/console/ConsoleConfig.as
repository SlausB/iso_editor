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
package com.junkbyte.console {

	public class ConsoleConfig {
		
		//////////////////////
		//                  //
		//  LOGGING CONIFG  //
		//                  //
		//////////////////////
		
		/**
		 * Maximum number of logs Console should remember.
		 * 0 = unlimited. Setting to very high will take up more memory and potentially slow down.
		 */
		public var maxLines:uint = 1000;
		
		/**
		 * Frames before repeating line is forced to print to next line.
		 * <p>
		 * Set to -1 to never force. Set to 0 to force every line.
		 * Default = 75;
		 * </p>
		 */
		public var maxRepeats:int = 75;
		
		/**
		 * Auto stack trace logs for this priority and above
		 * default priortiy = 10; fatal level
		 */
		public var autoStackPriority:int = Console.FATAL;

		/**
		 * Default stack trace depth
		 */
		public var defaultStackDepth:int = 2;
		
		/** 
		 * Object linking allows you click on individual objects you have logged to inspect the detials in a specific view.
		 * The down side is that it will take a little more memory to keep a WEAK reference to all objects pass for logging.
		 * Potentially a security risk as users will be able to explore your code interface.
		 */
		public var useObjectLinking:Boolean = true;
		
		/**
		 * Seconds in which object links should be hard referenced for.
		 * If you logged a temp object (object that is not referenced anywhere else), it will become a link in console. 
		 * However it will get garbage collected almost straight away which prevents you from clicking on the object link. 
		 * (You will normally get this message: "Reference no longer exists")
		 * This feature allow you to set how many seconds console should hard reference object logs.
		 * Example, if you set 120, you will get 2 mins guaranteed time that any object link will work since it first appeared.
		 * Default is 0, meaning everything is weak linked straight away.
		 * Recommend not to use too high numbers. possibly 120 (2 minutes) is max you should set.
		 * 
		 * Example:
		 * <code>
		 * Cc.log("This is a temp object:", new Object());
		 * // if you click this link in run time, it'll most likely say 'no longer exist'.
		 * // However if you set objectHardReferenceTimer to 60, you will get AT LEAST 60 seconds before it become unavailable.
		 * </code>
		 */
		public var objectHardReferenceTimer:uint = 0;
		
		/**
		 * Use flash's build in (or external) trace().
		 * <p>
		 * When turned on, Console will also call trace() for all console logs.
		 * Trace function can be replaced with something of your own (such as Flex's logging) by
		 * setting your own function into traceCall variable.
		 * Default function: trace("["+channel+"] "+text);
		 * </p>
		 * @see traceCall
		 */
		public var tracing:Boolean;
		
		/**
		 * Assign custom trace function.
		 * <p>
		 * Console will only call this when Cc.config.tracing is set to true.<br/>
		 * Custom function must accept 3 parameters:<br/>
		 * - String channel name.<br/>
		 * - String the log line.<br/>
		 * - int    priority level -2 to 10.
		 * </p>
		 * <p>
		 * Default function calls flash build-in trace in this format: "[channel] log line" (ignores priority)
		 * Example:
		 * Cc.config.traceCall = function(ch:String, line:String, level:int):void {
		 * 	  trace("["+ch+"] "+line);
		 * }
		 * </p>
		 * @see tracing
		 */
		public var traceCall:Function = function (ch:String, line:String, ...args):void
		{
			trace("["+ch+"] "+line);
		};
		
		///////////////////////
		//                   //
		//  REMOTING CONFIG  //
		//                   //
		///////////////////////
		
		/** 
		 * Shared connection name used for remoting 
		 * You can change this if you don't want to use default channel
		 * Other remotes with different remoting channel won't be able to connect your flash.
		 * Start with _ to work in any domain + platform (air/swf - local / network)
		 * Note that local to network sandbox still apply.
		 */
		public var remotingConnectionName:String = "_Console";
		
		/**
		 * allowDomain and allowInsecureDomain of remoting LocalConnection.
		 * Default: "*"
		 * see LocalConnection -> allowDomain for info.
		 */
		public var allowedRemoteDomain:String = "*";
		
		///////////////////
		//               //
		//  MISC CONFIG  //
		//               //
		///////////////////
		
		
		/**
		 * Full Command line features usage allowance.
		 * <p>
		 * CommandLine is a big security risk for your code and flash. 
		 * It is a very good practice to disable it after development phase.
		 * On the other hand having it on full access will let you debug the code easier.
		 * </p>
		 */
		public var commandLineAllowed:Boolean;
		
		/**
		 * Command line autoscoping
		 * <p>
		 * When turned on, it will autoscope to objects returned without the need to call the command "/".
		 * </p>
		 */
		public var commandLineAutoScope:Boolean;
		
		/**
		 * Key binding availability
		 * <p>
		 * While turned off, you can still bind keys. 
		 * Just that it will not trigger so long as the keyBindsEnabled is set to false.
		 * </p>
		 */
		public var keyBindsEnabled:Boolean = true;
		
		/**
		 *Display Roller availability
		 * <p>
		 * You are able to turn it off incase you need better security.
		 * </p>
		 */
		public var displayRollerEnabled:Boolean = true;
		
		/**
		 * Determine if Console should hide the mouse cursor when using Ruler tool.
		 * <p>
		 * You may want to turn it off if your app/game don't use system mouse.
		 * Default: true
		 * </p>
		 */
		public var rulerHidesMouse:Boolean = true;
		
		/** 
		 * Local shared object used for storing user data such as command line history
		 * Set to null to disable storing to local shared object.
		 */
		public var sharedObjectName:String = "com.junkbyte/Console/UserData";
		
		/** Local shared object path */
		public var sharedObjectPath:String = "/";
		
		/*
		 * When set to quiet, console will refrain from printing too many internal information 
		 * <p>
		 * It will stop tracing about start of storing and watching objects - and a few others.
		 * If not sure, keep it to false.
		 * </p>
		public var quiet:Boolean;
		 */
		
		/**
		 * Keeping Console on top of display list.
		 * <p>
		 * When turned on (by default), console will always try to put it self on top of the parent's display list.
		 * For example, if console is started in root, when a child display is added in root, console will move it self to the 
		 * top of root's display list to try to overlay the new child display. - making sure that console don't get covered.
		 * </p>
		 * <p>
		 * However, if Console's parent display (root in example) is covered by another display (example: adding a child directly to stage), 
		 * console will not be able to pull it self above it as it is in root, not stage.
		 * If console is added on stage in the first place, there won't be an issue as described above. Use Cc.startOnStage(...).
		 * </p>
		 * <p>
		 * Keeping it turned on may have other side effects if another display is also trying to put it self on top, 
		 * they could be jumping layers as they fight for the top layer.
		 * </p>
		 */
		public var alwaysOnTop:Boolean = true;
		
		////////////////////
		//                //
		//  STYLE CONFIG  //
		//                //
		////////////////////
		
		public function get style():ConsoleStyle{
			return _style;
		}
		
		/////////////////////
		//                 //
		//  END OF CONFIG  //
		//                 //
		/////////////////////
		
		private var _style:ConsoleStyle;
		
		public function ConsoleConfig(){
			_style = new ConsoleStyle();
		}
	}
}