//
// $Id$

package ghostbusters.server {

import com.threerings.util.Log;

import flash.geom.Point;
import flash.utils.Dictionary;

import ghostbusters.data.Codes;
import ghostbusters.data.GhostDefinition;
import ghostbusters.server.util.Formulae;

public class Ghost
{
    public static var log :Log = Log.getLog(Room);

    public static function resetGhost (id :String, level :int) :Dictionary
    {
        var data :Dictionary = new Dictionary();
        data[Codes.IX_GHOST_ID] = id;
        data[Codes.IX_GHOST_NAME] = buildName(id);
        data[Codes.IX_GHOST_LEVEL] = level;

        // max zest at level 1 is 50  //SKIN we don't need this
//        data[Codes.IX_GHOST_CUR_ZEST] = data[Codes.IX_GHOST_MAX_ZEST] =
//            50 * Formulae.quadRamp(level);

        // max health at level 1 is 50
        data[Codes.IX_GHOST_CUR_HEALTH] = data[Codes.IX_GHOST_MAX_HEALTH] =
            50 * Formulae.quadRamp(level);//SKIN 50 -> 40, the games are hard...

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

    public function get level () :int
    {
        return _level;
    }

    public function get zest () :int
    {
        return 0;//SKIN
//        return _zest;
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
        zest = Math.max(0, Math.min(_maxZest, zest));
        if (zest == _zest) {
            return;
        }

        _zest = zest;
        _zest = 0;//SKIN
        _room.ctrl.props.setIn(Codes.DICT_GHOST, Codes.IX_GHOST_CUR_ZEST, _zest);
    }

    public function setHealth (health :int) :void
    {
        health = Math.max(0, Math.min(_maxHealth, health));
        if (health == _health) {
            return;
        }

        _health = health;
        _room.ctrl.props.setIn(Codes.DICT_GHOST, Codes.IX_GHOST_CUR_HEALTH, health);
    }

    public function setPosition (x :Number, y :Number) :void
    {
        _position = new Point(x, y);

        _room.ctrl.props.setIn(Codes.DICT_GHOST, Codes.IX_GHOST_POS, [ x, y ]);
    }

    public function zap (who :Player) :void
    {
        setZest(_zest - 10*Formulae.quadRamp(who.level));
    }

    public function heal () :void
    {
        setHealth(_maxHealth);
        setZest(_maxZest);
    }

    public function tick (seconds :int) :void
    {
        if (_room.state == Codes.STATE_FIGHTING && _brain != null) {
            _brain.tick(seconds);
        }

        // a level 1 ghost heals 0.25 hp/second, but let's not bother with fractional healing
        setHealth(_health + Math.floor(0.25 * Formulae.quadRamp(_level)));
//        if (_room.state == Codes.STATE_SEEKING) {//SKIN we don't bother with zest
//            setZest(_zest + 1);
//        }
    }

    public function calculateSingleAttack () :int
    {
        // a level 1 ghost does 5-6 points of direct dmg to a target
        return Formulae.rndStretch(5 * Formulae.quadRamp(_level), 1.2);
    }

    public function calculateSplashAttack () :int
    {
        // a level 1 ghost does 2-3 points of splash damage to everyone in a group
//        return Formulae.rndStretch(5 * Formulae.quadRamp(_level), 1.5);
        return Formulae.rndStretch(5 * Formulae.quadRamp(_level), 1.5);
    }

    // TODO: build more interesting names
    protected static function buildName (ghostId :String) :String
    {
        switch(ghostId) {//SKIN
//            case GhostDefinition.GHOST_DEMON:
//                return "Soul Crusher";
            case GhostDefinition.GHOST_MCCAIN:
                return "Senator McCain";
            case GhostDefinition.GHOST_MUTANT:
                return "GOP Monster";
            case GhostDefinition.GHOST_PALIN:
                return "Governor Palin";
        }
        log.warning("Name of unknown ghost requested", "id", ghostId);
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
