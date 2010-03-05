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
package org.osmf.net
{
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The NetStreamSeekTrait class extends SeekTrait for NetStream-based seeking.
	 * 
	 * @see flash.net.NetStream
	 */ 		
	public class NetStreamSeekTrait extends SeekTrait
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 		
		public function NetStreamSeekTrait(temporal:TimeTrait, netStream:NetStream)
		{
			super(temporal);
			
			this.netStream = netStream;
			NetClient(netStream.client).addHandler(NetStreamCodes.ON_META_DATA, onMetaData);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			
			seekBugTimer = new Timer(10, 100);
			seekBugTimer.addEventListener(TimerEvent.TIMER, onSeekBugTimer, false, 0, true);	
			seekBugTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onSeekBugTimerDone, false, 0, true);		
		}

		/**
		 * @private
		 * Communicates a <code>seeking</code> change to the media through the NetStream. 
		 * @param newSeeking New <code>seeking</code> value.
		 * @param time Time to seek to, in seconds.
		 */						
		override protected function seekingChangeStart(newSeeking:Boolean, time:Number):void
		{
			if (newSeeking)
			{
				suppressSeekNotifyEvent  = false;
				previousTime = timeTrait.currentTime;
				expectedTime = time;
				netStream.seek(time + audioDelay);
				
				if (previousTime == expectedTime)
				{
					// Manually start the seekBugTimer, because NetStream
					// sometimes doesn't trigger an event when seeking to
					// its current position (FM-227), causing the seek to
					// never get closed.
					seekBugTimer.start();
					
					// Note that this event gets triggered "sometimes".
					// If it does, then we want to suppress it (until the
					// next seek operation, hence the clearing of it
					// earlier in this method).
					suppressSeekNotifyEvent = true;
				}
			}
		}
		
		private function onMetaData(value:Object):void
		{						
			audioDelay = value.hasOwnProperty("audiodelay") ? value.audiodelay : 0;
		}
				
		private function onNetStatus(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case NetStreamCodes.NETSTREAM_SEEK_NOTIFY:
					// There's a bug (FP-1705) where NetStream.time doesn't get
					// updated until *after* the NetStream.Seek.Notify event is
					// received.  We don't want to processSeekCompletion until
					// NetStream's state is consistent, so we use a Timer to
					// delay the processing until the NetStream.time property
					// is up-to-date.
					// Note that we don't start the Timer if we've been
					// instructed to suppress the event.
					if (suppressSeekNotifyEvent == false)
					{
						seekBugTimer.start();
					}
					else
					{
						suppressSeekNotifyEvent = false;
					}
					break;
				case NetStreamCodes.NETSTREAM_SEEK_INVALIDTIME:
				case NetStreamCodes.NETSTREAM_SEEK_FAILED:
					setSeeking(false, previousTime);
					break;
			}
		}
				
		private function onSeekBugTimer(event:TimerEvent):void
		{
			// As soon as our NetStream.time value has changed from the value
			// it had when the seek was initiated, we assume the seek has
			// completed. Note that the playhead may not actually be at the
			// seeked-to position, since it will land on the nearest keyframe
			// (which might be seconds away).   Addresses bug FM-258.
			// The second condition is to cover the case where the seek time
			// is the same as the current time (bug FM-227).
			if (   previousTime != netStream.time
				|| previousTime == expectedTime
			   )
			{
				onSeekBugTimerDone(null);
			}			
		}
		
		private function onSeekBugTimerDone(event:TimerEvent):void
		{
			seekBugTimer.reset();
			setSeeking(false, expectedTime);
		}
		
		private var audioDelay:Number = 0;
		private var seekBugTimer:Timer;
		private var netStream:NetStream;
		private var expectedTime:Number;
		private var previousTime:Number;
		private var suppressSeekNotifyEvent:Boolean = false;
	}
}