package com.threerings.defense.units {
    
import flash.geom.Point;

import com.threerings.defense.Board;
    
public class Critter extends Unit
{
    public static const TYPE_WEAK :int = 1;

    /** Target position on board. */
    public var target :Point;

    /** Distance to target position, in board units. */
    public var delta :Point;

    /** Current velocity vector, in board units per second. */
    public var vel :Point;

    /** Max velocity, in board units per second, for each axis. */
    public var maxvel :Number;

    /** Critter type, one of TYPE_* constants. */
    public var type :int;

    /** Locations where missiles will try to hit (relative to current board position,
     *  potentially fractional) */
    public var missileHotspot :Point;

    /** Critter health. Once it drops below zero, it's gone! */
    public var health :Number;

    /** How many points is this critter worth? */
    public var pointValue :Number;
    
    public function Critter (x :int, y :int, type :int, player :int)
    {
        super(player, x, y, 1, 1);

        this.type = type;
        this.vel = new Point(0, 0);
        this.target = new Point(x, y);
        this.delta = new Point(0, 0);
        this.missileHotspot = new Point(size.x / 2, - size.y / 2); 
        
        // the following will (eventually) be overwritten from unit definitions:

        this.pointValue = 1;
        this.maxvel = 1;
        this.health = 3;
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
