// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.filters.DropShadowFilter;

import mx.core.MovieClipAsset;

/**
 * A sprite class that exposes some of the methods to its underlying movie, and handles rotation
 * correctly (the marble movie rotates, but not the glare or drop shadow).
 */
public class MarbleMovie extends Sprite
{
    public function MarbleMovie (type :int) 
    {
        addChild(_movie = new (type == Marble.MOON ? MOON_BALL : SUN_BALL)() as MovieClipAsset);
        _movie.cacheAsBitmap = true;
        var shine :DisplayObject = new BALL_SHINE() as DisplayObject;
        shine.cacheAsBitmap = true;
        addChild(shine);
        filters = [ DROP_SHADOW ];
        cacheAsBitmap = true;
    }

    public override function get rotation () :Number
    {
        return _movie.rotation;
    }

    public override function set rotation (value :Number) :void
    {
        _movie.rotation = value;
    }

    public function get totalFrames () :int
    {
        return _movie.totalFrames;
    }

    public function gotoAndStop (frame :int) :void
    {
        _movie.gotoAndStop(frame);
    }

    public function gotoAndPlay (frame :int) :void
    {
        _movie.gotoAndPlay(frame);
    }

    public function play () :void
    {
        _movie.play();
    }

    public function stop () :void
    {
        _movie.stop();
    }

    [Embed(source="../rsrc/locksmith_art.swf#ball_sun")]
    protected static const SUN_BALL :Class;
    [Embed(source="../rsrc/locksmith_art.swf#ball_moon")]
    protected static const MOON_BALL :Class;
    [Embed(source="../rsrc/locksmith_art.swf#ball_shine")]
    protected static const BALL_SHINE :Class;

    protected static const DROP_SHADOW :DropShadowFilter = 
        new DropShadowFilter(5, 90, 0x563C15, 1, 5, 5);

    protected var _movie :MovieClipAsset;
}
}
