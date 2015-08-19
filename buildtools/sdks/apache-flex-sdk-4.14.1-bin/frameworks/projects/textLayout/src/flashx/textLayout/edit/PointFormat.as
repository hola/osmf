////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package flashx.textLayout.edit
{
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	use namespace tlf_internal;
	
	[ExcludeClass]
	/**
	 * Contains the settings that apply to new text being typed.
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	public class PointFormat extends TextLayoutFormat implements ITextLayoutFormat
	{
		private var _id:*;
		private var _linkElement:LinkElement;
		private var _tcyElement:TCYElement;
		
		/** Constructor
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function PointFormat(initialValues:ITextLayoutFormat = null)
		{
			super(initialValues);
		}
		

		static public function isEqual(p1:ITextLayoutFormat,p2:ITextLayoutFormat):Boolean
		{
			if (!TextLayoutFormat.isEqual(p1, p2))
				return false;
			if ((p1 is PointFormat) != (p2 is PointFormat))
				return false;
			if (p1 is PointFormat)
			{
				var pf1:PointFormat = p1 as PointFormat;
				var pf2:PointFormat = p2 as PointFormat;
				return pf1.id == pf2.id && isEqualLink(pf1.linkElement, pf2.linkElement) && 
					(pf1.tcyElement == null) == (pf2.tcyElement == null);
			}
			return true;
		}
		
		static private function isEqualLink(l1:LinkElement, l2:LinkElement):Boolean
		{
			if ((l1 == null) != (l2 == null))
				return false;
			if (l1 == null)
				return true;
			return l1.href == l2.href && l1.target == l2.target;
		}
		
		
		public function get linkElement():*
		{
			return _linkElement;
		}
		public function set linkElement(value:LinkElement):void
		{
			_linkElement = value;
		}

		public function get tcyElement():*
		{
			return _tcyElement;
		}
		public function set tcyElement(value:TCYElement):void
		{
			_tcyElement = value;
		}
		/**
		 * Assigns an identifying name to the element, making it possible to set a style for the element
		 * by referencing the <code>id</code>. 
		 *
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * 
		 * @see FlowElement#id
		 */
		public function get id():*
		{
			return _id;
		}
		public function set id(value:*):void
		{
			_id = value;
		}
 
		
		tlf_internal static function clone(original:PointFormat):PointFormat
		{
			var cloneFormat:PointFormat = new PointFormat(original);
			cloneFormat.id = original.id;
			cloneFormat.linkElement = (original.linkElement === undefined || !original.linkElement) ? original.linkElement : original.linkElement.shallowCopy() as LinkElement;
			cloneFormat.tcyElement = (original.tcyElement === undefined || !original.tcyElement) ? original.tcyElement : original.tcyElement.shallowCopy() as TCYElement;
			return cloneFormat;
		}
		
		tlf_internal static function createFromFlowElement(element:FlowElement):PointFormat
		{
			if (!element)
				return new PointFormat();
			
			var format:PointFormat = new PointFormat(element.format);
			

			var linkElement:LinkElement = element.getParentByType(LinkElement) as LinkElement;
			if (linkElement)
				format.linkElement = linkElement.shallowCopy() as LinkElement;

			var tcyElement:TCYElement = element.getParentByType(TCYElement) as TCYElement;
			if (tcyElement)
				format.tcyElement = tcyElement.shallowCopy() as TCYElement;
			
			return format;
		}
	}
}