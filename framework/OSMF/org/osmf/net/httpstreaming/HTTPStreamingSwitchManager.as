/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
package org.osmf.net.httpstreaming
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetStreamMetricsBase;
	import org.osmf.net.NetStreamSwitchManager;
	import org.osmf.net.SwitchingRuleBase;
	
	[ExcludeClass]

	/**
	 * HTTPStreamingSwitchManager is making switching decisions at the end of each 
	 * fragment, instead of using the timer mechanism which is being used in NetStreamSwitchManager.
	 */ 
	public class HTTPStreamingSwitchManager extends NetStreamSwitchManager
	{
		public function HTTPStreamingSwitchManager(connection:NetConnection, netStream:NetStream, resource:DynamicStreamingResource, metrics:NetStreamMetricsBase, switchingRules:Vector.<SwitchingRuleBase>)
		{
			super(connection, netStream, resource, metrics, switchingRules);
			
			super.autoSwitch = false;
			
			this.netStream = netStream;
		}
		
		/**
		 * @private
		 * 
		 * For HTTP Streaming, autoSwitch should always be false.
		 */
		override public function set autoSwitch(value:Boolean):void
		{
			if (value)
			{
				netStream.addEventListener(HTTPStreamingEvent.FRAGMENT_END, onFragmentEnd);
			}
			else
			{
				netStream.removeEventListener(HTTPStreamingEvent.FRAGMENT_END, onFragmentEnd);
			}
		}
		
		/**
		 * @private
		 * 
		 * When a fragment download has been complete, we need to call checkRules of the base
		 * class to update critical ratios such as DownloadRatio.
		 */
		private function onFragmentEnd(event:HTTPStreamingEvent):void
		{
			doCheckRules();
		}
		
		private var _autoSwitch:Boolean = false;
		private var netStream:NetStream;
	}
}