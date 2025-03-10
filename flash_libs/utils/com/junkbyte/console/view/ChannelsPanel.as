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
package com.junkbyte.console.view {
	import com.junkbyte.console.Console;
	
	import flash.events.TextEvent;
	import flash.text.TextFieldAutoSize;		

	public class ChannelsPanel extends AbstractPanel{
		
		public static const NAME:String = "channelsPanel";
		
		public function ChannelsPanel(m:Console) {
			super(m);
			name = NAME;
			init(10,10,false);
			txtField = makeTF("channelsField");
			txtField.wordWrap = true;
			txtField.width = 160;
			txtField.multiline = true;
			txtField.autoSize = TextFieldAutoSize.LEFT;
			registerTFRoller(txtField, onMenuRollOver, linkHandler);
			registerDragger(txtField);
			addChild(txtField);
		}
		public function update():void{
			txtField.wordWrap = false;
			txtField.width = 80;
			var str:String = "<w><menu> <b><a href=\"event:close\">X</a></b></menu> "+ console.panels.mainPanel.getChannelsLink();
			txtField.htmlText = str+"</w>";
			if(txtField.width>160){
				txtField.wordWrap = true;
				txtField.width = 160;
			}
			width = txtField.width+4;
			height = txtField.height;
		}
		private function onMenuRollOver(e:TextEvent):void{
			console.panels.mainPanel.onMenuRollOver(e, this);
		}
		protected function linkHandler(e:TextEvent):void{
			txtField.setSelection(0, 0);
			if(e.text == "close"){
				console.panels.channelsPanel = false;
			}else if(e.text.substring(0,8) == "channel_"){
				console.panels.mainPanel.onChannelPressed(e.text.substring(8));
			}
			txtField.setSelection(0, 0);
			e.stopPropagation();
		}
	}
}