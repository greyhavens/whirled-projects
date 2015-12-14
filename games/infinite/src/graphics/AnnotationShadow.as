package graphics
{
    import flash.display.DisplayObject;
    import flash.filters.DropShadowFilter;
    
    public class AnnotationShadow 
    {
        public static function makeShadow() :DropShadowFilter
        {
            const filter:DropShadowFilter = new DropShadowFilter();
            with (filter) {
                angle = 90;
                strength = 0.5;
                distance = 8;
                blurX = 16;
                blurY = 16;
            }
            return filter;
        }
        
        public static function applyTo (target:DisplayObject) :void
        {
            const filters:Array = new Array();
            filters.push(makeShadow());
            target.filters = filters;
        }
    }
}