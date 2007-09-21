package com.threerings.defense.units {
    
import flash.geom.Point;
import flash.utils.getTimer; // function import

import com.threerings.defense.Board;
import com.threerings.defense.tuning.UnitDefinitions;
    
public class Missile extends Unit
{
    public static const TYPE_SQUIRT_GUN :int = 1;
    public static const TYPE_SLINGSHOT :int = 2;
    public static const TYPE_PAPER_AIRPLANE :int = 3;
    public static const TYPE_SPORTS_BALL :int = 4;
    public static const TYPE_WATER_BALLOON :int = 5;
    public static const TYPE_BOOMERANG :int = 6;
    public static const TYPE_SPITBALL :int = 6;
    

    /** Missile type, one of the TYPE_* constants. */
    public var type :int;

    /** Source that fired the missile. */
    public var source :Tower;

    /** Target where the missile is headed. */
    public var target :Critter;

    /** Distance to target, in board units. */
    public var delta :Point;
    
    /** Current velocity vector, in board units per second. */
    public var vel :Point;

    /** Max velocity, in board units per second. */
    public var maxvel :Number; 

    /** How much damage this missile inflicts on the critter. */
    public var damage :Number;

    /** Activation time, in milliseconds since the beginning of epoch. */
    public var activationTime :int;
    
    /** Creation time, in milliseconds since the beginning of epoch. */
    public var creationTime :int;
    
    public function Missile (source :Tower, target :Critter, type :int, player :int)
    {
        var startx :Number = source.pos.x + source.missileHotspot.x;
        var starty :Number = source.pos.y + source.missileHotspot.y;
        super(player, startx, starty, 0.5, 0.5);

        this.type = type;
        this.source = source;
        this.target = target;
        this.delta = new Point(Infinity, Infinity); // this will be recalculated anyway
        this.vel = new Point(0, 0);
        this.creationTime = getTimer();
        
        UnitDefinitions.initializeMissile(type, this);
    }

    // from Unit
    override public function get centroidx () :Number
    {
        return Board.SQUARE_WIDTH * pos.x;
    }

    // from Unit
    override public function get centroidy () :Number
    {
        return Board.SQUARE_HEIGHT * pos.y;
    }

    public function getAgeMs () :int
    {
        return getTimer() - activationTime;
    }

    public function isActive () :Boolean
    {
        return getAgeMs() > 0;
    }
}
}
