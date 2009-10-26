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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.media
{
	import org.osmf.net.NetLoader;
	import org.osmf.proxies.TemporalProxyElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.NetFactory;
	import org.osmf.utils.TestConstants;
	import org.osmf.utils.URL;
	
	public class TestMediaPlayerWithTemporalProxyElement extends TestMediaPlayer
	{
		// Overrides
		//
				
		override protected function createMediaElement(resource:IMediaResource):MediaElement
		{
			return new TemporalProxyElement(1);
		}
		
		override protected function get loadable():Boolean
		{
			return false;
		}
		
		override protected function get resourceForMediaElement():IMediaResource
		{
			return new URLResource(new URL("http://example.com"));
		}

		override protected function get invalidResourceForMediaElement():IMediaResource
		{
			return null;
		}
		
		override protected function get existentTraitTypesOnInitialization():Array
		{
			return [MediaTraitType.TEMPORAL, MediaTraitType.SEEKABLE, MediaTraitType.PLAYABLE, MediaTraitType.PAUSABLE];
		}

		override protected function get existentTraitTypesAfterLoad():Array
		{
			return [MediaTraitType.TEMPORAL, MediaTraitType.SEEKABLE, MediaTraitType.PLAYABLE, MediaTraitType.PAUSABLE];
		}
	}
}