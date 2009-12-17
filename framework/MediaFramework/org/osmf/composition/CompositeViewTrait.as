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
package org.osmf.composition
{
	import flash.display.DisplayObject;
	import flash.errors.IllegalOperationError;
	
	import org.osmf.events.ViewEvent;
	import org.osmf.layout.DefaultLayoutRenderer;
	import org.osmf.layout.ILayoutContext;
	import org.osmf.layout.ILayoutRenderer;
	import org.osmf.layout.LayoutContextSprite;
	import org.osmf.layout.LayoutRendererFacet;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.IFacet;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.metadata.MetadataUtils;
	import org.osmf.traits.ViewTrait;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * Composite ViewTrait.
	 * 
	 * The view property of the composite trait refers to a
	 * DisplayObjectContainer implementing instance, that holds each of the composite trait
	 * children's DisplayObject.
	 * 
	 * The bounds of the container determine the intrinsic size of the composition.
	 * 
	 * The characteristics of a composite trait changing influence
	 * the container's characteristics - hence the trait needs to watch these traits on
	 * its children.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	internal class CompositeViewTrait extends ViewTrait
	{
		public function CompositeViewTrait(traitAggregator:TraitAggregator, owner:MediaElement)
		{
			super(null);
			
			_traitAggregator = traitAggregator;
			_owner = owner as CompositeElement;
			
			// Prepare a container to hold our viewable children:
			_container = constructLayoutContext();
			_container.addEventListener
				( ViewEvent.DIMENSION_CHANGE
				, onContainerDimensionChange
				);
			
			// Watch our owner's metadata for a layout class being set:
			MetadataUtils.watchFacet
				( owner.metadata
				, MetadataNamespaces.LAYOUT_RENDERER
				, layoutRendererFacetChangeCallback
				);
		}
		
		/**
		 * @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 **/
		override public function get view():DisplayObject
		{
			// The aggregate view is the container holding the composite
			// trait's children:
			return _container.view;
		}

		/**
		 * @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		override public function get mediaWidth():Number
		{
			return _container.intrinsicWidth;
		}
		
		/**
		 * @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		override public function get mediaHeight():Number
		{
			return _container.intrinsicHeight;
		}
		
		// Protected API
		//
		
		protected function get layoutRenderer():ILayoutRenderer
		{
			return _layoutRenderer;
		}
		
		protected function get traitAggregator():TraitAggregator
		{
			return _traitAggregator;
		}
		
		protected function get owner():CompositeElement
		{
			return _owner;
		}
		
		protected function get container():ILayoutContext
		{
			return _container;
		}
		
		// Internals
		//
		
		private function constructLayoutContext():ILayoutContext
		{
			return new LayoutContextSprite(_owner.metadata);
		}

		private function onContainerDimensionChange(event:ViewEvent):void
		{
			// Re-dispatch the event.
			dispatchEvent(event.clone());
		}

		private function layoutRendererFacetChangeCallback(facet:IFacet):void
		{
			if (_layoutRenderer)
			{
				_layoutRenderer.context = null;
				_layoutRenderer = null;
			}
			
			var layoutRendererFacet:LayoutRendererFacet
				= facet as LayoutRendererFacet;
				
			if (layoutRendererFacet)
			{
				try
				{
					_layoutRenderer
						= new layoutRendererFacet.rendererType()
						as ILayoutRenderer;
				}
				catch (e:*)
				{
					throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_LAYOUTRENDERER_CONSTRUCTOR));
				}
			}
			
			if (_layoutRenderer == null)
			{
				_layoutRenderer = new DefaultLayoutRenderer();
			}
			
			_container.layoutRenderer = _layoutRenderer;
			_layoutRenderer.context = _container;
		}

		private var _traitAggregator:TraitAggregator;		
		private var _owner:CompositeElement;
		private var _container:ILayoutContext;
		private var _layoutRenderer:ILayoutRenderer;
	}
}