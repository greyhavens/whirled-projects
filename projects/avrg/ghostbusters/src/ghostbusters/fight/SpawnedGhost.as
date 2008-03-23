//
// $Id$

package ghostbusters.fight {

import ghostbusters.Codes;
import ghostbusters.Game;
import ghostbusters.GhostBase;

import com.threerings.util.CommandEvent;
import com.whirled.AVRGameControlEvent;

public class SpawnedGhost extends GhostBase
{
    public function SpawnedGhost ()
    {
        super();

        Game.control.state.addEventListener(AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);
    }

    override protected function mediaReady () :void
    {
        fighting();
    }

    public function fighting () :void
    {
        _next = ST_FIGHT;
        play();
    }

    protected function messageReceived (evt :AVRGameControlEvent) :void
    {
        if (evt.name == Codes.MSG_TICK && Game.control.hasControl() && !Game.model.isGhostDead()) {
            _brainTick(evt.value as int);
        }
    }

    protected function play () :void
    {
        if (_next == ST_FIGHT) {
            handler.gotoScene(Codes.ST_GHOST_FIGHT, play);

        } else if (_next == ST_REEL) {
            _next = ST_FIGHT;
            handler.gotoScene(Codes.ST_GHOST_REEL, play);

        } else if (_next == ST_ATTACK) {
            _next = ST_FIGHT;
            handler.gotoScene(Codes.ST_GHOST_RETALIATE, play);

        } else if (_next == ST_DIE) {
            handler.gotoScene(Codes.ST_GHOST_DEFEAT, _callback);

        } else {
            Game.log.debug("unknown state: " + _next);
            handler.gotoScene(Codes.ST_GHOST_FIGHT, play);
        }
    }

    public function damaged () :void
    {
        Game.log.debug("Ghost damaged [_next=" + _next + "]");
        _next = ST_FIGHT;
        handler.gotoScene(Codes.ST_GHOST_REEL, play);
    }

    public function attack () :void
    {
        Game.log.debug("Ghost attacking [_next=" + _next + "]");
        _next = ST_FIGHT;
        handler.gotoScene(Codes.ST_GHOST_RETALIATE, play);
    }

    public function die (callback :Function) :void
    {
        Game.log.debug("Ghost dying [_next=" + _next + "]");
        _callback = callback;
        _next = ST_DIE;
    }

    public function triumph (callback :Function) :void
    {
        Game.log.debug("Ghost triumphant [_next=" + _next + "]");
        handler.gotoScene(Codes.ST_GHOST_TRIUMPH, callback);
    }

    protected var _next :int;
    protected var _callback :Function;

    protected static const ST_FIGHT :int = 0;
    protected static const ST_REEL :int = 1;
    protected static const ST_ATTACK :int = 2;
    protected static const ST_DIE :int = 3;
}
}
