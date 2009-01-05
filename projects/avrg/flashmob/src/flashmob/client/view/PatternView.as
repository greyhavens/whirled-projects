package flashmob.client.view {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import flashmob.*;
import flashmob.client.*;
import flashmob.data.*;
import flashmob.util.SpriteUtil;

public class PatternView extends SceneObject
{
    public function PatternView (pattern :Pattern)
    {
        _pattern = pattern;

        _sprite = SpriteUtil.createSprite();
        _shape = new Shape();
        _sprite.addChild(_shape);

        updateView();
    }

    public function showInPositionIndicators (inPositionFlags :Array) :void
    {
        updateView(inPositionFlags);
    }

    override protected function addedToDB () :void
    {
        // Don't intercept mouse clicks
        ClientContext.hitTester.addExcludedObj(this.displayObject);
    }

    override protected function destroyed () :void
    {
        ClientContext.hitTester.removeExcludedObj(this.displayObject);
    }

    protected function updateView (inPositionFlags :Array = null) :void
    {
        var g :Graphics = _shape.graphics;
        g.clear();
        g.lineStyle(2, 0);

        for (var ii :int = 0; ii < _pattern.locs.length; ++ii) {
            var loc :PatternLoc = _pattern.locs[ii];
            var inPosition :Boolean = (inPositionFlags != null ? inPositionFlags[ii] : false);
            g.beginFill(inPosition ? 0x00FF00 : 0xFFFFFF);
            g.drawCircle(loc.x, loc.y, Constants.PATTERN_DOT_SIZE);
            g.endFill();
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
    protected var _shape :Shape;
}

}
