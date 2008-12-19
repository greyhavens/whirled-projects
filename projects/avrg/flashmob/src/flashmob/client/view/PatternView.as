package flashmob.client.view {

import com.threerings.flash.DisplayUtil;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;

import flashmob.client.*;
import flashmob.data.*;
import flashmob.util.SpriteUtil;

public class PatternView extends SceneObject
{
    public function PatternView (pattern :Pattern)
    {
        _pattern = pattern;

        _sprite = SpriteUtil.createSprite();

        if (_pattern.locs.length > 0) {
            var shape :Shape = new Shape();
            var g :Graphics = shape.graphics;
            var firstLoc :PatternLoc = _pattern.locs[0];
            var xOff :Number = -firstLoc.x;
            var yOff :Number = -firstLoc.y;

            for each (var loc :PatternLoc in _pattern.locs) {
                g.lineStyle(2, 0);
                g.beginFill(0xFFFFFF);
                g.drawCircle(loc.x + xOff, loc.y + yOff, 15);
                g.endFill();

                log.info("Adding dot: ", "loc", loc);
            }

            DisplayUtil.positionBounds(shape, 0, 0);
            _sprite.addChild(shape);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected static function get log () :Log
    {
        return FlashMobClient.log;
    }

    protected var _pattern :Pattern;
    protected var _sprite :Sprite;
}

}
