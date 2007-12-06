//
// $Id$

package ghostbusters {

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

public class Ghost extends Sprite
{
    public function Ghost (roomId :int)
    {
        _pather = new SplinePather();

        _random = new Random(roomId);

        _speed = 150 + 100 * _random.nextNumber();

        var loader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
        loader.addEventListener(Event.COMPLETE, handleGhostLoaded);
        loader.load(ByteArray(new GHOST()));
    }

    public function isIdle () :Boolean
    {
        return _pather.idle == 1;
    }

    public function getGhostBounds () :Rectangle
    {
        return _bounds;
    }

    public function slow () :Boolean
    {
        // this reduction rate will depend later on weapon level vs ghost level
        var newSpeed :Number = (_speed * 0.8 - 20);
        if (newSpeed < 10) {
            _speed = 0;
            _pather.adjustRate(0);
            return true;
        }
        Log.getLog(Ghost).debug("new speed: " + newSpeed + "; adjustment: " + (newSpeed / _speed));
        _pather.adjustRate(newSpeed / _speed);
        _speed = newSpeed;
        return false;
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

    protected function handleGhostLoaded (evt :Event) :void
    {
        var sprite :MovieClip = MovieClip(EmbeddedSwfLoader(evt.target).getContent());
        sprite.gotoAndPlay(1, "state_Default_walking"); // standardize
        addChild(sprite);
        _bounds = sprite.getBounds(this);

        // dangle the sprite from its head
        sprite.x = - (_bounds.left + _bounds.width/2);
        sprite.y = - _bounds.top;

        // refigure the bounds
        _bounds = sprite.getBounds(this);
    }

    protected var _pather :SplinePather;
    protected var _random :Random;

    protected var _bounds :Rectangle;

    protected var _speed :Number;

    [Embed(source="../../rsrc/Ghost.swf", mimeType="application/octet-stream")]
    protected static const GHOST :Class;
}
}
