//
// $Id$

package ghostbusters.client {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.utils.ByteArray;

import flash.events.Event;

import flash.geom.Point;
import flash.geom.Rectangle;

import com.threerings.util.Log;

import ghostbusters.client.ClipHandler;
import ghostbusters.client.Content;

public class Ghost extends Sprite
{
    public var handler :ClipHandler;

    public function Ghost (clip :Class, pos :Point, readyCallback :Function)
    {
        handler = new ClipHandler(new clip(), setupUI);
        this.addChild(handler);

        _readyCallback = readyCallback;
        _pather = new SplinePather(pos);
    }

    public function isIdle () :Boolean
    {
        return _pather.idle;
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

        _pather.newTarget(p, d / 200, true);
    }

    public function appear () :int
    {
        return handler.gotoScene(GamePanel.ST_GHOST_APPEAR, function () :String {
            // stay in FIGHT state for the brief period until the entire SeekPanel disappears
            return GamePanel.ST_GHOST_FIGHT;
        });
    }

    public function hidden () :void
    {
        handler.gotoScene(GamePanel.ST_GHOST_HIDDEN, function () :String {
            return GamePanel.ST_GHOST_HIDDEN;
        });
    }

    public function get bounds () :Rectangle
    {
        return _bounds;
    }

    public function fighting () :void
    {
        _next = ST_FIGHT;
        play();
    }

    public function damaged () :void
    {
        _log.debug("Ghost damaged [_next=" + _next + "]");
        _next = ST_FIGHT;
        handler.gotoScene(GamePanel.ST_GHOST_REEL, play);
    }

    public function attack () :void
    {
        _log.debug("Ghost attacking [_next=" + _next + "]");
        _next = ST_FIGHT;
        handler.gotoScene(GamePanel.ST_GHOST_RETALIATE, play);
    }

    public function die (callback :Function = null) :void
    {
        _log.debug("Ghost dying [_next=" + _next + "]");
        _callback = callback;
        _next = ST_DIE;
    }

    public function triumph (callback :Function = null) :void
    {
        _log.debug("Ghost triumphant [_next=" + _next + "]");
        handler.gotoScene(GamePanel.ST_GHOST_TRIUMPH, callback);
    }

    protected function setupUI () :void
    {
        var ghost :MovieClip = handler.clip;

        ghost.gotoAndStop(1, GamePanel.ST_GHOST_HIDDEN);
        _bounds = ghost.getBounds(this);

        // register the sprite
        ghost.x = - (_bounds.left + _bounds.width/2);
        ghost.y = - _bounds.top;

        // refigure the bounds
        _bounds = ghost.getBounds(this);

        _log.debug("Ghost finished loading [bounds=" + _bounds + "]");

        if (_readyCallback != null) {
            _readyCallback(this);
        }
    }

    protected function play () :void
    {
        if (_next == ST_FIGHT) {
            handler.gotoScene(GamePanel.ST_GHOST_FIGHT, play);

        } else if (_next == ST_REEL) {
            _next = ST_FIGHT;
            handler.gotoScene(GamePanel.ST_GHOST_REEL, play);

        } else if (_next == ST_ATTACK) {
            _next = ST_FIGHT;
            handler.gotoScene(GamePanel.ST_GHOST_RETALIATE, play);

        } else if (_next == ST_DIE) {
            handler.gotoScene(GamePanel.ST_GHOST_DEFEAT, _callback);

        } else {
            _log.debug("unknown state: " + _next);
            handler.gotoScene(GamePanel.ST_GHOST_FIGHT, play);
        }
    }

    protected var _bounds :Rectangle;
    protected var _pather :SplinePather;
    protected var _next :int;
    protected var _readyCallback :Function;
    protected var _callback :Function;

    protected static const ST_FIGHT :int = 0;
    protected static const ST_REEL :int = 1;
    protected static const ST_ATTACK :int = 2;
    protected static const ST_DIE :int = 3;

    protected static const _log :Log = Log.getLog(Ghost);
}
}
