package org.osmf.utils
{
    import flash.external.ExternalInterface;
    public class ZErr
    {
        public function ZErr()
        {
            super();
        }
        public static function log(msg:String, ...rest:Array):void{
            if (!ExternalInterface.available)
                    return;
            ExternalInterface.call.apply(ExternalInterface,
                ['console.log', msg].concat(rest))
        }
    }
}
