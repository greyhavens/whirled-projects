package com.threerings.defense.units {

import flash.geom.Point;

import com.threerings.defense.Game;
import com.threerings.defense.tuning.UnitDefinitions;
    
/**
 * Definition of a single tower, including all state information, and a pointer to display object.
 * Towers occupy rectangular subsets of the board.
 */
public class Tower extends Unit
{
    public static const TYPE_INVALID  :int = 0;
    public static const TYPE_SANDBOX  :int = 1;
    public static const TYPE_BOULDER  :int = 2;
    public static const TYPE_WAGON    :int = 3;
    public static const TYPE_BOX      :int = 4;
    public static const TYPE_SHRUB    :int = 5;
    public static const TYPE_TRASHCAN :int = 6;
    public static const TYPE_TREE     :int = 7;

    public static const ALL_TYPES :Array =
        [ TYPE_SANDBOX, TYPE_BOULDER, TYPE_WAGON, TYPE_BOX, TYPE_SHRUB, TYPE_TRASHCAN, TYPE_TREE ];
    
    /** Position on the tower (in board units, potentially fractional, from the upper left)
     *  from which missiles should be fired. */
    public var missileHotspot :Point;

    /** Minimum firing distance, in board units squared. */
    public var rangeMinSq :Number = 0;

    /** Maximum firing distance, in board units squared. */
    public var rangeMaxSq :Number = 0;

    /** Firing delay between missiles, in seconds. */
    public var firingDelay :Number = 1;

    /** Tower type, one of the TYPE_* constants. */
    protected var _type :int;

    /** Game time when the tower will be able to fire again. */
    protected var _nextFiringTime :Number = 0;

    public function Tower (x :Number, y :Number, type :int, player :int, guid :int)
    {
        super(player, x, y, 1, 1);
        updateFromType(type);
    }

    public function get type () :int { return _type; }

    
    public function updateFromType (value :int) :void
    {
        // remember type
        _type = value;
        UnitDefinitions.initializeTower(_type, this);

        // now update missile hotspot from size
        missileHotspot = new Point(size.x / 2, size.y / 2);
    }

    /** Checks if the tower can fire at anything right now, and if so, returns a target critter;
     *  otherwise returns null. */
    public function canFire (game :Game, gameTime :Number) :Critter
    {
        if (gameTime <= _nextFiringTime) {
            return null; // be patient
        }
        
        return findTargetCritter(game);
    }

    /** Creates a missile and fires it at the critter. */
    public function fireAt (critter :Critter, game :Game, gameTime :Number) :void
    {
        // got one, let's fire!
        var missileType :int = UnitDefinitions.getMissileType(this.type);
        var missile :Missile = new Missile(this, critter, missileType, player);
        game.handleAddMissile(missile);

        // now cool down
        _nextFiringTime = gameTime + firingDelay;
    }

    /** Returns a target critter within range, or null if none could be found. */
    protected function findTargetCritter (game :Game) :Critter
    {
        var critters :Array = game.getCritters();
        for each (var critter :Critter in critters) {
                var dx :Number = pos.x - critter.pos.x;
                var dy :Number = pos.y - critter.pos.y;
                var dsquared :Number = dx * dx + dy * dy;
                if (dsquared >= rangeMinSq && dsquared <= rangeMaxSq) {
                    return critter;
                }
            }
        
        return null;
    }

                    
    public function serialize () :Object
    {
        return { x: this.pos.x, y: this.pos.y, type: this.type,
                 player: this.player, guid: this.guid };
    }

    public static function deserialize (obj :Object) :Tower
    {
        return new Tower(obj.x, obj.y, obj.type, obj.player, obj.guid);
    }

    override public function toString () :String
    {
        return "Tower " + _type + super.toString();
    }
}
}
