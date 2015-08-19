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

package mx.utils
{

import flash.display.DisplayObject;
import flash.utils.getQualifiedClassName;
import mx.core.IRepeaterClient;

/**
 *  The NameUtil utility class defines static methods for
 *  creating names for Flex objects.
 *  You do not create instances of NameUtil;
 *  instead you call static methods of the class, such as 
 *  the <code>NameUtil.createName()</code> method.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class NameUtil
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static var counter:int = 0;

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Creates a unique name for any Object instance, such as "Button12", by
     *  combining the unqualified class name with an incrementing counter.
     *
     *  @param object Object requiring a name.
     *
     *  @return String containing the unique name.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function createUniqueName(object:Object):String
    {
        if (!object)
            return null;

        var name:String = getQualifiedClassName(object);
        
        // If there is a package name, strip it off.
        var index:int = name.indexOf("::");
        if (index != -1)
            name = name.substr(index + 2);
                        
        // If the class name ends with a digit (which some autogenerated
        // classes do), then append an underscore before appending
        // the counter.
        var charCode:int = name.charCodeAt(name.length - 1);
        if (charCode >= 48 && charCode <= 57)
            name += "_";
        
        return name + counter++;
    }

    /**
     *  Returns a string, such as
     *  "MyApplication0.addressForm.lastName.TextField17",
     *  for a DisplayObject object that indicates its position in the
     *  hierarchy of DisplayObject objects in an application.
     *
     *  @param displayObject A DisplayObject object whose hierarchy in the application
     *  is desired. 
     *
     *  @return String containing the position of <code>displayObject</code> 
     *  in the hierarchy of DisplayObject objects in an application.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function displayObjectToString(
                                displayObject:DisplayObject):String
    {
        var result:String;

        // Start at the specified object and walk up the parent chain
        // to build up the string to return.
        try
        {
            for (var o:DisplayObject = displayObject;
                 o != null;
                 o = o.parent)
            {
                // If this object is in the display tree,
                // stop after we've prepended the topmost Application instance.
                if (o.parent && o.stage && o.parent == o.stage)
                    break;
    
                // Prefer id over name if specified.
                var s:String = "id" in o && o["id"] ? o["id"] : o.name;
                
                if (o is IRepeaterClient)
                {
                    var indices:Array = IRepeaterClient(o).instanceIndices;
                    if (indices)
                        s += "[" + indices.join("][") + "]";
                }
    
                result = result == null ? s : s + "." + result;
            }
        }
        catch (e:SecurityError)
        {
            // Ignore error and continue with what we have. 
            // We may not have access to our parent if we are loaded into a sandbox.
        }
        
        return result;
    }

    /**
     *  Returns the name of the specified object's class,
     *  such as <code>"Button"</code>
     *
     *  <p>This string does not include the package name.
     *  If you need the package name as well, call the
     *  <code>getQualifiedClassName()</code> method in the flash.utils package.
     *  It will return a string such as <code>"mx.controls::Button"</code>.</p>
     *
     *  @param object The object.
     *
     *  @return The name of the specified object's class.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function getUnqualifiedClassName(object:Object):String
    {
        var name:String;
        if (object is String)
            name = object as String;
        else
            name = getQualifiedClassName(object);

        // If there is a package name, strip it off.
        var index:int = name.indexOf("::");
        if (index != -1)
            name = name.substr(index + 2);

        return name;
    }
}

}
