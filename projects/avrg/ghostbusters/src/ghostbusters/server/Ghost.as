//
// $Id$

package ghostbusters.server {

import flash.geom.Point;
import flash.utils.Dictionary;

import ghostbusters.Codes;

public class Ghost
{
    public static function resetGhost (id :String, name :String, level :int) :Dictionary
    {
        var data :Dictionary = new Dictionary();

        data[Codes.PROP_GHOST_ID] = id;
        data[Codes.PROP_GHOST_NAME] = name;
        data[Codes.PROP_GHOST_LEVEL] = level;

        // TODO: in time, zest should depend on level
        data[Codes.PROP_GHOST_CUR_ZEST] = data[Codes.PROP_GHOST_MAX_ZEST] =
            150 + 100 * Server.random.nextNumber();

        // TODO: in time, max health should depend on level
        data[Codes.PROP_GHOST_CUR_HEALTH] = data[Codes.PROP_GHOST_MAX_HEALTH] = 100;

        return data;
    }

    public function Ghost (room :Room, data :Dictionary)
    {
        _room = room;
        _brain = new BasicBrain(room);

        // TODO: if we're really going to configure through dictionary, we need sanity checks
        _id = data[Codes.PROP_GHOST_ID];
        _name = data[Codes.PROP_GHOST_NAME];
        _level = data[Codes.PROP_GHOST_LEVEL];

        _zest = data[Codes.PROP_GHOST_CUR_ZEST];
        _maxZest = data[Codes.PROP_GHOST_MAX_ZEST];

        _health = data[Codes.PROP_GHOST_CUR_HEALTH];
        _maxHealth = data[Codes.PROP_GHOST_MAX_HEALTH];

    }

    public function get zest () :int
    {
        return _zest;
    }

    public function get health () :int
    {
        return _health;
    }

    public function isDead () :Boolean
    {
        return _health == 0;
    }

    public function setZest (zest :int) :void
    {
        _zest = zest;

        _room.ctrl.props.setIn(Codes.PROP_GHOST, Codes.PROP_GHOST_CUR_ZEST, zest);
    }

    public function setHealth (health :int) :void
    {
        _health = health;

        _room.ctrl.props.setIn(Codes.PROP_GHOST, Codes.PROP_GHOST_CUR_HEALTH, health);
    }

    public function setPosition (x :int, y :int) :void
    {
        _position = new Point(x, y);

        _room.ctrl.props.setIn(Codes.PROP_GHOST, Codes.PROP_GHOST_POS, [ x, y ]);
    }

    public function zap () :void
    {
        setZest(_zest*0.9 - 15);
    }

    public function heal () :void
    {
        setHealth(_maxHealth);
        setZest(_maxZest);
    }

    public function tick (timer :int) :void
    {
        if (_brain != null) {
            _brain.tick(timer);
        }
    }

    public function calculateSingleAttack () :int
    {
        // e.g. a level 3 ghost does 40-48 points of dmg to one target
        return rndStretch(10 * (_level + 1), 1.2);
    }

    public function calculateSplashAttack () :int
    {
        // e.g. a level 3 ghost does 16-24 points of dmg to the whole party
        return rndStretch(4 * (_level + 1), 1.5);
    }

    protected function rndStretch (n :int, f :Number) :int
    {
        // randomly stretch a value by a factor [1, f]
        return int(n * (1 + (f-1)*Server.random.nextNumber()));
    }

    protected var _room :Room;

    protected var _id :String;
    protected var _name :String;
    protected var _level :int;

    protected var _zest :int;
    protected var _maxZest :int;

    protected var _health :int;
    protected var _maxHealth :int;

    protected var _position :Point;

    protected var _brain :BasicBrain;
}

}
