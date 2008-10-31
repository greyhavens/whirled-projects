package popcraft.util {

import flash.display.Sprite;
import flash.display.MovieClip;

import com.threerings.util.ClassUtil;

public class SpriteUtil
{
    public static const USE_CACHE :Boolean = true;

    public static function createSprite (mouseChildren :Boolean = false,
        mouseEnabled :Boolean = false) :Sprite
    {
        var sprite :Sprite = new Sprite();
        sprite.mouseChildren = mouseChildren;
        sprite.mouseEnabled = mouseEnabled;
        return sprite;
    }

    public static function newMC (mcClass :Class) :MovieClip
    {
        if (!USE_CACHE) {
            return new mcClass() as MovieClip;
        }
        var cache :Array = getCache(mcClass);
        return (cache.length > 0 ? cache.pop() : new mcClass()) as MovieClip;
    }

    public static function releaseMC (mc :MovieClip) :void
    {
        if (!USE_CACHE) {
            return;
        }
        if (mc.parent != null) {
            mc.parent.removeChild(mc);
        }
        mc.gotoAndStop(1);
        getCache(ClassUtil.getClass(mc)).push(mc);
    }

    public static function getCache (c :Class) :Array
    {
        return (_mcCache[c] == null ? _mcCache[c] = new Array() : _mcCache[c]);
    }

    protected static var _mcCache :Object = new Object();
}

}
