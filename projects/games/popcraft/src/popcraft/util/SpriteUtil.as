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
        if (cache.length > 0) {
            var mc :MovieClip = cache.pop();
            mc.gotoAndPlay(1);
            return mc;
        }
        return new mcClass() as MovieClip;
    }

    public static function releaseMC (mc :MovieClip) :void
    {
        if (!USE_CACHE) {
            return;
        }
        if (mc.parent != null) {
            mc.parent.removeChild(mc);
        }
        mc.stop();
        getCache(ClassUtil.getClass(mc)).push(mc);
    }

    public static function getCache (c :Class) :Array
    {
        return (_mcCache[c] == null ? _mcCache[c] = new Array() : _mcCache[c]);
    }

    protected static var _mcCache :Object = new Object();
}

}
