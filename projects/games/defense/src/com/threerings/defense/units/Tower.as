package com.threerings.defense.units {

import flash.geom.Point;

import com.threerings.defense.Game;
    
/**
 * Definition of a single tower, including all state information, and a pointer to display object.
 * Towers occupy rectangular subsets of the board.
 */
public class Tower extends Unit
{
    public static const TYPE_INVALID :int = 0;
    public static const TYPE_SIMPLE :int = 1;

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

    
    public function Tower (x :int, y :int, type :int, player :int, guid :int)
    {
        super(player, x, y, 1, 1);
        updateFromType(type);
    }

    public function get type () :int { return _type; }

    
    public function updateFromType (value :int) :void
    {
        // remember type
        _type = value;

        // update size from type
        switch(_type) {
        case Tower.TYPE_SIMPLE:
            size.x = size.y = 2;
            rangeMaxSq = 16;
            firingDelay = 2;
            break;
        default:
            size.x = size.y = 1;
        }

        // now update missile hotspot from size
        missileHotspot = new Point(size.x / 2, size.y / 2);
    }

    public function fireIfPossible (game :Game, gameTime :Number) :void
    {
        if (gameTime <= _nextFiringTime) {
            return; // be patient
        }
        
        var critter :Critter = findTargetCritter(game);
        if (critter == null) {
            return; // critters are too far!
        }
        
        // got one, let's fire!
        var missileType :int = Missile.missileTypeForTower(this.type);
        var missile :Missile = new Missile(this, critter, type, player);
        game.handleAddMissile(missile);

        // now cool down
        _nextFiringTime = gameTime + firingDelay;
    }

    public function findTargetCritter (game :Game) :Critter
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
