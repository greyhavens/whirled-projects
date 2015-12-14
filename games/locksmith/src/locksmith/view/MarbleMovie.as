//
// $Id$

package locksmith.view {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

/**
 * A sprite class that exposes some of the methods to its underlying movie, and handles rotation
 * correctly (the marble movie rotates, but not the glare or drop shadow).
 */
public class MarbleMovie extends Sprite
{
    public function MarbleMovie (type :int)
    {
        addChild(new BALL_SHADOW() as DisplayObject);
//        addChild(_movie = new (type == Marble.MOON ? MOON_BALL : SUN_BALL)() as MovieClip);
//        _movie.cacheAsBitmap = true;
//        var shine :DisplayObject = 
//            new (type == Marble.MOON ? BALL_SHINE_MOON : BALL_SHINE_SUN)() as DisplayObject;
//        shine.cacheAsBitmap = true;
//        addChild(shine);
//        cacheAsBitmap = true;
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

    [Embed(source="../../../rsrc/locksmith_art.swf#ball_sun")]
    protected static const SUN_BALL :Class;
    [Embed(source="../../../rsrc/locksmith_art.swf#ball_shine_sun")]
    protected static const BALL_SHINE_SUN :Class;
    [Embed(source="../../../rsrc/locksmith_art.swf#ball_moon")]
    protected static const MOON_BALL :Class;
    [Embed(source="../../../rsrc/locksmith_art.swf#ball_shine_moon")]
    protected static const BALL_SHINE_MOON :Class;

    [Embed(source="../../../rsrc/locksmith_art.swf#ball_shadow")]
    protected static const BALL_SHADOW :Class;

    protected var _movie :MovieClip;
}
}
