//
// $Id$

package ghostbusters.seek {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.utils.ByteArray;

import flash.events.Event;

import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.Log;
import com.threerings.util.Random;

import ghostbusters.GhostBase;
import ghostbusters.SplinePather;

public class HidingGhost extends GhostBase
{
    public function HidingGhost (speed :int)
    {
        super();

        _speed = speed;
        _pather = new SplinePather();
    }

    public function isIdle () :Boolean
    {
        return _pather.idle;
    }

    public function setSpeed (newSpeed :Number) :void
    {
        _pather.adjustRate(newSpeed / _speed);
        _speed = newSpeed;
    }

    public function nextFrame () :void
    {
        _pather.nextFrame();

        this.x = _pather.x;
        this.y = _pather.y;
    }

    public function newTarget (p :Point) :void
    {
        var dX :Number = p.x - _pather.x;
        var dY :Number = p.y - _pather.y;
        var d :Number = Math.sqrt(dX*dX + dY*dY);

        _pather.newTarget(p, d / _speed, true);
    }

    public function appear (callback :Function) :int
    {
        return _handler.gotoScene(STATE_APPEAR, function () :void {
            _clip.stop();
            callback();
        });
    }

    override protected function mediaReady () :void
    {
        super.mediaReady();

        // not sure why gotoAndPlay doesn't work here, it loops through all the damn scenes
        _clip.gotoAndStop(1, STATE_WALKING);
    }

    protected var _pather :SplinePather;
    protected var _random :Random;

    protected var _speed :Number;
}
}
