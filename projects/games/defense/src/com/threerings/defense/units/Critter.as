package com.threerings.defense.units {
    
import flash.geom.Point;

import com.threerings.defense.Board;
import com.threerings.defense.tuning.UnitDefinitions;
    
public class Critter extends Unit
{
    public static const TYPE_BULLY :int = 1;
    public static const TYPE_GIRL :int = 2;
    public static const TYPE_BIRD :int = 3;
    public static const TYPE_SQUIRREL :int = 4;
    public static const TYPE_SKATER :int = 5;
    public static const TYPE_SKUNK :int = 6;
    public static const TYPE_CAT :int = 7;
    public static const TYPE_YETI :int = 8;
    public static const TYPE_CRAB :int = 9;
    
    /** Target position on board. */
    public var target :Point;

    /** Distance to target position, in board units. */
    public var delta :Point;

    /** Current velocity vector, in board units per second. */
    public var vel :Point;

    /** Max velocity, in board units per second, for each axis. */
    public var maxspeed :Number;

    /** Critter type, one of TYPE_* constants. */
    public var type :int;

    /** Locations where missiles will try to hit (relative to current board position,
     *  potentially fractional) */
    public var missileHotspot :Point;

    /** Critter health. Once it drops below zero, it's gone! */
    public var health :Number;

    /** Critter's starting health. */
    public var maxhealth :Number;

    /** How many points is this critter worth? */
    public var pointValue :Number;

    /** Powerup value for this critter, per difficulty level. */
    public var powerup :Number;
    
    /** Is this a flying critter? If so, it will ignore obstacles. */
    public var isFlying :Boolean;
    
    public function Critter (x :int, y :int, type :int, player :int, level :uint)
    {
        super(player, x, y, 1, 1);

        this.type = type;
        this.vel = new Point(0, 0);
        this.target = new Point(x, y);
        this.delta = new Point(0, 0);
        this.missileHotspot = new Point(size.x / 2, - size.y / 2); 
        
        UnitDefinitions.initializeCritter(type, this, level);
    }

    // position of the sprite centroid in screen coordinates
    override public function get centroidx () :Number
    {
        return Board.SQUARE_WIDTH * (pos.x + size.x / 2);
    }

    override public function get centroidy () :Number
    {
        return Board.SQUARE_HEIGHT * (pos.y + size.y / 2);
    }

}
}
