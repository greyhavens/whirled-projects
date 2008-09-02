//
// $Id$

package ghostbusters.server {

import com.threerings.util.Log;

import flash.geom.Point;
import flash.utils.Dictionary;

import ghostbusters.data.Codes;
import ghostbusters.data.GhostDefinition;

public class Ghost
{
    public static var log :Log = Log.getLog(Room);

    public static function resetGhost (id :String, level :int) :Dictionary
    {
        var data :Dictionary = new Dictionary();
        data[Codes.IX_GHOST_ID] = id;
        data[Codes.IX_GHOST_NAME] = buildName(id);
        data[Codes.IX_GHOST_LEVEL] = level;

        // TODO: in time, zest should depend on level
        data[Codes.IX_GHOST_CUR_ZEST] = data[Codes.IX_GHOST_MAX_ZEST] =
            150 + 100 * Server.random.nextNumber();

        // TODO: in time, max health should depend on level
        data[Codes.IX_GHOST_CUR_HEALTH] = data[Codes.IX_GHOST_MAX_HEALTH] = 100;

        return data;
    }

    public function Ghost (room :Room, data :Dictionary)
    {
        _room = room;
        _brain = new BasicBrain(room);

        // TODO: if we're really going to configure through dictionary, we need sanity checks
        _id = data[Codes.IX_GHOST_ID];

        _def = GhostDefinition.getDefinition(_id);

        _name = data[Codes.IX_GHOST_NAME];
        _level = data[Codes.IX_GHOST_LEVEL];

        _zest = data[Codes.IX_GHOST_CUR_ZEST];
        _maxZest = data[Codes.IX_GHOST_MAX_ZEST];

        _health = data[Codes.IX_GHOST_CUR_HEALTH];
        _maxHealth = data[Codes.IX_GHOST_MAX_HEALTH];
    }

    public function get id () :String
    {
        return _id;
    }

    public function get definition () :GhostDefinition
    {
        return _def;
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

        _room.ctrl.props.setIn(Codes.DICT_GHOST, Codes.IX_GHOST_CUR_ZEST, zest);
    }

    public function setHealth (health :int) :void
    {
        _health = health;

        _room.ctrl.props.setIn(Codes.DICT_GHOST, Codes.IX_GHOST_CUR_HEALTH, health);
    }

    public function setPosition (x :int, y :int) :void
    {
        _position = new Point(x, y);

        _room.ctrl.props.setIn(Codes.DICT_GHOST, Codes.IX_GHOST_POS, [ x, y ]);
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

    // TODO: build more interesting names
    protected static function buildName (ghostId :String) :String
    {
        switch(ghostId) {
            case GhostDefinition.GHOST_DEMON:
                return "Soul Crusher";
            case GhostDefinition.GHOST_DUCHESS:
                return "The Duchess";
            case GhostDefinition.GHOST_PINCHER:
                return "Mr. Pinchy";
            case GhostDefinition.GHOST_WIDOW:
                return "The Widow";
        }
        log.warning("Name of unknown ghost requested [id=" + ghostId + "]");
        return "Unknown Ghost";
    }

    protected var _room :Room;

    protected var _id :String;

    protected var _def :GhostDefinition;

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
