//
// $Id$

package ghostbusters.fight {

import ghostbusters.Codes;
import ghostbusters.Game;
import ghostbusters.GhostBase;

public class SpawnedGhost extends GhostBase
{
    public function SpawnedGhost ()
    {
        super();
    }

    public function fighting () :void
    {
        _next = ST_FIGHT;
        play();
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
        if (_next == ST_FIGHT) {
            _next = ST_REEL;
        }
    }

    public function attack () :void
    {
        if (_next == ST_FIGHT || _next == ST_REEL) {
            _next = ST_ATTACK;
        }
    }

    public function die (callback :Function) :void
    {
        _callback = callback;
        _next = ST_DIE;
    }

    protected var _next :int;
    protected var _callback :Function;

    protected static const ST_FIGHT :int = 0;
    protected static const ST_REEL :int = 1;
    protected static const ST_ATTACK :int = 2;
    protected static const ST_DIE :int = 3;
}
}
