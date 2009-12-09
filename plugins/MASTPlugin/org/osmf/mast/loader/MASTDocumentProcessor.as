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
*  Contributor(s): Akamai Technologies
* 
*****************************************************/
package org.osmf.mast.loader
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.mast.managers.MASTConditionManager;
	import org.osmf.mast.model.*;
	import org.osmf.media.MediaElement;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.utils.URL;
	import org.osmf.vast.loader.VASTLoadedContext;
	import org.osmf.vast.loader.VASTLoader;
	import org.osmf.vast.media.DefaultVASTMediaFileResolver;
	import org.osmf.vast.media.IVASTMediaFileResolver;
	import org.osmf.vast.media.VASTMediaGenerator;
	
	/**
	 * This class process a MAST document by working with the 
	 * objects in the MAST object model.
	 * 
	 * @see org.osmf.mast.model.MASTDocument
	 */
	public class MASTDocumentProcessor extends EventDispatcher
	{
		// Supported source formats
		private static const SOURCE_FORMAT_VAST:String = "vast";
		
		/**
		 * Constructor.
		 */
		public function MASTDocumentProcessor()
		{
			super();
		}
		
		/**
		 * Processes a MAST document represented as a MASTDocument
		 * object, the root of the MAST document object model.
		 * 
		 * @param document The MASTDocument object to process.
		 * @param mediaElement The main content, usually a video, the
		 * MASTDocument object will work with.
		 * 
		 * @return True if the condition causes a pending play request, 
		 * such as a preroll ad.
		 */
		public function processDocument(document:MASTDocument, mediaElement:MediaElement):Boolean
		{
			var causesPendingPlayRequest:Boolean = false;
			
			// Set up a listener for each trigger.
			for each (var trigger:MASTTrigger in document.triggers)
			{
				var condition:MASTCondition;
				
				for each (condition in trigger.startConditions)
				{
					if (processMASTCondition(trigger, condition, mediaElement, true))
					{
						causesPendingPlayRequest = true;
					}
				}

				for each (condition in trigger.endConditions)
				{
					processMASTCondition(trigger, condition, mediaElement, false);
				}
			}
			
			return causesPendingPlayRequest;
		}
		
		/**
		 * Loads any payload (source) associated with a trigger.
		 * <p>
		 * To add support for an additional payload, override this
		 * method.
		 * </p>
		 */
		public function loadSources(trigger:MASTTrigger, condition:MASTCondition):void
		{
			for each (var source:MASTSource in trigger.sources)
			{
				if (source.format == SOURCE_FORMAT_VAST)
				{
					loadVastDocument(source, condition);
				}
			}
		}
		
		/**
		 * Process a single condition object.
		 * 
 		 * @return True if the condition causes a pending play request, 
		 * such as a preroll ad.
		 */
		private function processMASTCondition(trigger:MASTTrigger, condition:MASTCondition, 
												mediaElement:MediaElement, start:Boolean):Boolean
		{
			var conditionManager:MASTConditionManager = new MASTConditionManager();
			conditionManager.addEventListener(MASTConditionManager.CONDITION_TRUE, onConditionTrue);
			var causesPendingPlayRequest:Boolean = conditionManager.setContext(mediaElement, condition, start);
		
			function onConditionTrue(event:Event):void
			{
				conditionManager.removeEventListener(MASTConditionManager.CONDITION_TRUE, onConditionTrue);
				loadSources(trigger, condition);
			}
			
			return causesPendingPlayRequest;
		}
		
		/**
		 * Loads a VAST document specified in the MASTSource object.
		 * 
		 * @param source The MASTSource object containing the VAST document to load.
		 * @param condition The MASTCondition object that is causing the source to be loaded.
		 */
		public function loadVastDocument(source:MASTSource, condition:MASTCondition):void
		{
			var loadTrait:LoadTrait
				= new LoadTrait(new VASTLoader(), new URLResource(new URL(source.url)));
			
			loadTrait.addEventListener
				( LoadEvent.LOAD_STATE_CHANGE
				, onLoadStateChange
				);
			loadTrait.load();
			
			function onLoadStateChange(event:LoadEvent):void
			{
				if (event.loadState == LoadState.READY)
				{
					loadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
						
					// Get the appropriate inline MediaElements.
					var loadedContext:VASTLoadedContext = loadTrait.loadedContext as VASTLoadedContext;
					var generator:VASTMediaGenerator = new VASTMediaGenerator();
					var resolver:IVASTMediaFileResolver = new DefaultVASTMediaFileResolver();
					
					dispatchEvent(new MASTDocumentProcessedEvent(generator.createMediaElements(loadedContext.vastDocument), condition));
				}
			}
		}
	}
}
