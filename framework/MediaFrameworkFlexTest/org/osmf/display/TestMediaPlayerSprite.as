/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.display
{
	import flash.display.Sprite;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.ViewTrait;
	import org.osmf.utils.DynamicMediaElement;

	public class TestMediaPlayerSprite extends TestCase
	{
		public function testMediaPlayer():void
		{
			var player:MediaPlayerSprite = new MediaPlayerSprite();
			var element:DynamicMediaElement = new DynamicMediaElement();
			var viewTrait:ViewTrait = new ViewTrait(new Sprite(), 150, 150);
						
			Sprite(viewTrait.view).graphics.beginFill(0);
			Sprite(viewTrait.view).graphics.drawRect(0,0,150,150);
			
			player.element = element;
			
			element.doAddTrait(MediaTraitType.VIEW, viewTrait);
			
			player.scaleMode = ScaleMode.NONE;
			
			player.setAvailableSize(300, 300);
			
			assertEquals( viewTrait.view.width, viewTrait.view.height, 150);
			
			player.scaleMode = ScaleMode.STRETCH;
			
			assertEquals( viewTrait.view.width, viewTrait.view.height, 300);
						
			player.setAvailableSize(500, 500);
			
			assertEquals( viewTrait.view.width, viewTrait.view.height, 500);
			
			player.scaleMode = ScaleMode.NONE;
						
			// Sanity checks
			player.element = null;
			player.setAvailableSize(0,0);
			assertNull(player.element);
			assertEquals(player.width, player.height, 0);
		}
	}
}